require 'ferrum'
require 'resolv'
require 'ipaddr'

class RecipeScraperService
  attr_reader :url, :errors

  BROWSER_HEADERS = {
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language" => "en-US,en;q=0.9",
    "Cache-Control" => "no-cache"
  }.freeze

  # RFC 1918 / RFC 6890 private & reserved ranges
  BLOCKED_RANGES = [
    IPAddr.new("0.0.0.0/8"),
    IPAddr.new("10.0.0.0/8"),
    IPAddr.new("100.64.0.0/10"),
    IPAddr.new("127.0.0.0/8"),
    IPAddr.new("169.254.0.0/16"),
    IPAddr.new("172.16.0.0/12"),
    IPAddr.new("192.0.0.0/24"),
    IPAddr.new("192.0.2.0/24"),
    IPAddr.new("192.168.0.0/16"),
    IPAddr.new("198.18.0.0/15"),
    IPAddr.new("198.51.100.0/24"),
    IPAddr.new("203.0.113.0/24"),
    IPAddr.new("224.0.0.0/4"),
    IPAddr.new("240.0.0.0/4"),
    IPAddr.new("255.255.255.255/32"),
    IPAddr.new("::1/128"),
    IPAddr.new("fc00::/7"),
    IPAddr.new("fe80::/10"),
  ].freeze
  
  def initialize(url)
    @url = url
    @errors = []
  end
  
  def scrape
    return nil unless url.present?

    unless safe_url?
      @errors << "URL is not allowed (private or reserved address)"
      return nil
    end

    html = fetch_with_httparty
    html = fetch_with_headless_browser if html.nil? && @use_browser_fallback

    return nil if html.nil?

    doc = Nokogiri::HTML(html)

    recipe_data = extract_json_ld(doc)
    return recipe_data if recipe_data

    extract_from_meta_and_selectors(doc)
  end
  
  private

  # SSRF protection: resolve the hostname and reject private/reserved IPs
  def safe_url?
    host = URI.parse(url).host
    return false if host.blank?

    addrs = Resolv.getaddresses(host)
    return false if addrs.empty?

    addrs.all? do |addr_str|
      ip = IPAddr.new(addr_str)
      BLOCKED_RANGES.none? { |range| range.include?(ip) }
    end
  rescue URI::InvalidURIError, Resolv::ResolvError, IPAddr::InvalidAddressError
    false
  end

  # Fast path: plain HTTP request
  def fetch_with_httparty
    response = HTTParty.get(url, headers: BROWSER_HEADERS, timeout: 15, follow_redirects: true)

    if response.success?
      return response.body
    end

    # 403 typically means bot protection (Cloudflare, Akamai, etc.) — retry with a real browser
    if response.code == 403
      Rails.logger.info("[RecipeScraperService] 403 blocked for #{url}, will retry with headless browser")
      @use_browser_fallback = true
      return nil
    end

    @errors << "Failed to fetch URL: #{response.code}"
    nil
  rescue HTTParty::Error, Timeout::Error => e
    @errors << "Network error: #{e.message}"
    nil
  rescue StandardError => e
    @errors << "Error fetching URL: #{e.message}"
    nil
  end

  # Slow path: headless Chrome via Ferrum (handles Cloudflare JS challenges)
  # Slow path: headless Chrome via Ferrum (handles bot protection)
  def fetch_with_headless_browser
    attempt_browser_fetch
  end

  def attempt_browser_fetch
    Rails.logger.info("[RecipeScraperService] Fetching #{url} with headless browser")

    browser = Ferrum::Browser.new(
      headless: "new",
      timeout: 45,
      window_size: [1440, 900],
      browser_options: {
        "no-sandbox" => nil,
        "disable-gpu" => nil,
        "disable-dev-shm-usage" => nil,
        "disable-blink-features" => "AutomationControlled",
        "disable-features" => "ChromeWhatsNewUI",
        "user-agent" => BROWSER_HEADERS["User-Agent"]
      }
    )

    # Comprehensive anti-detection: mask headless signals
    browser.evaluate_on_new_document(<<~JS)
      // Hide webdriver flag
      Object.defineProperty(navigator, 'webdriver', { get: () => false });

      // Fake plugins (headless has none)
      Object.defineProperty(navigator, 'plugins', {
        get: () => [1, 2, 3, 4, 5]
      });

      // Fake languages
      Object.defineProperty(navigator, 'languages', {
        get: () => ['en-US', 'en']
      });

      // Override permissions query to avoid "denied" giveaway
      const originalQuery = window.navigator.permissions.query;
      window.navigator.permissions.query = (parameters) =>
        parameters.name === 'notifications'
          ? Promise.resolve({ state: Notification.permission })
          : originalQuery(parameters);

      // Fix chrome object (missing in headless)
      window.chrome = { runtime: {} };

      // Fake WebGL vendor/renderer (headless shows "Google SwiftShader")
      const getParameter = WebGLRenderingContext.prototype.getParameter;
      WebGLRenderingContext.prototype.getParameter = function(parameter) {
        if (parameter === 37445) return 'Intel Inc.';
        if (parameter === 37446) return 'Intel Iris OpenGL Engine';
        return getParameter.call(this, parameter);
      };
    JS

    browser.goto(url)
    wait_for_cloudflare_and_content(browser)

    html = browser.body
    browser.quit

    if html.blank? || html.length < 500 || html.include?("Just a moment")
      @errors = ["The site's bot protection could not be bypassed. Try creating the recipe manually."]
      return nil
    end

    html
  rescue Ferrum::Error, Ferrum::TimeoutError => e
    Rails.logger.warn("[RecipeScraperService] Browser error: #{e.message}")
    @errors = ["The site's bot protection could not be bypassed. Try creating the recipe manually."]
    nil
  rescue StandardError => e
    Rails.logger.warn("[RecipeScraperService] Unexpected error: #{e.message}")
    @errors = ["Unexpected error fetching the recipe. Please try again."]
    nil
  ensure
    browser&.quit rescue nil
  end

  def wait_for_cloudflare_and_content(browser)
    # Phase 1: Wait for Cloudflare challenge to clear (up to 20 seconds)
    # The page title changes from "Just a moment..." to the actual page title
    40.times do
      title = browser.evaluate("document.title") rescue ""
      break unless title.downcase.include?("just a moment") || title.downcase.include?("checking")
      sleep 0.5
    end

    # Small extra pause after Cloudflare clears for page to render
    sleep 1

    # Phase 2: Wait for recipe content to appear (up to 10 seconds)
    20.times do
      has_content = browser.evaluate(<<~JS) rescue false
        !!(
          document.querySelector('script[type="application/ld+json"]') ||
          document.querySelector('[itemprop="recipeIngredient"]') ||
          document.querySelector('.recipe-ingredients') ||
          document.querySelector('h1')
        )
      JS

      break if has_content
      sleep 0.5
    end
  end
  
  def extract_json_ld(doc)
    json_ld_scripts = doc.css('script[type="application/ld+json"]')
    
    json_ld_scripts.each do |script|
      begin
        data = JSON.parse(script.content)
        recipe = find_recipe_in_json_ld(data)
        
        if recipe
          return {
            title: recipe['name'] || recipe['headline'],
            description: recipe['description'],
            prep_time: parse_duration(recipe['prepTime']),
            cook_time: parse_duration(recipe['cookTime']),
            servings: parse_servings(recipe['recipeYield']),
            instructions: extract_instructions(recipe['recipeInstructions']),
            ingredients: recipe['recipeIngredient'] || [],
            image_url: extract_image_url(recipe['image'])
          }
        end
      rescue JSON::ParserError
        next
      end
    end
    
    nil
  end

  # Recursively search for a Recipe object in JSON-LD data
  # Handles: plain object, array of objects, @graph arrays, and @type as string or array
  def find_recipe_in_json_ld(data)
    return nil unless data

    if data.is_a?(Hash)
      return data if recipe_type?(data['@type'])

      # Check inside @graph (common in AllRecipes, NYT Cooking, etc.)
      if data['@graph'].is_a?(Array)
        data['@graph'].each do |item|
          result = find_recipe_in_json_ld(item)
          return result if result
        end
      end
    elsif data.is_a?(Array)
      data.each do |item|
        result = find_recipe_in_json_ld(item)
        return result if result
      end
    end

    nil
  end

  # @type can be "Recipe" or ["Recipe"] or ["Recipe", "SomethingElse"]
  def recipe_type?(type_value)
    return false unless type_value
    types = Array(type_value)
    types.any? { |t| t.to_s == 'Recipe' }
  end
  
  def extract_from_meta_and_selectors(doc)
    {
      title: extract_title(doc),
      description: extract_description(doc),
      image_url: extract_og_image(doc),
      ingredients: extract_ingredients_from_selectors(doc),
      instructions: extract_instructions_from_selectors(doc)
    }
  end
  
  def extract_title(doc)
    doc.css('h1').first&.text&.strip ||
      doc.at_css('meta[property="og:title"]')&.[]('content') ||
      doc.title
  end
  
  def extract_description(doc)
    doc.at_css('meta[name="description"]')&.[]('content') ||
      doc.at_css('meta[property="og:description"]')&.[]('content')
  end
  
  def extract_og_image(doc)
    doc.at_css('meta[property="og:image"]')&.[]('content')
  end
  
  def extract_ingredients_from_selectors(doc)
    # Common CSS selectors for ingredients
    selectors = [
      '.recipe-ingredients li',
      '.ingredients li',
      '[itemprop="recipeIngredient"]',
      '.ingredient'
    ]
    
    ingredients = []
    selectors.each do |selector|
      items = doc.css(selector)
      if items.any?
        ingredients = items.map { |item| item.text.strip }
        break
      end
    end
    
    ingredients
  end
  
  def extract_instructions_from_selectors(doc)
    # Common CSS selectors for instructions
    selectors = [
      '.recipe-instructions',
      '.instructions',
      '[itemprop="recipeInstructions"]',
      '.directions'
    ]
    
    selectors.each do |selector|
      element = doc.at_css(selector)
      return element.text.strip if element
    end
    
    nil
  end
  
  def parse_duration(iso_duration)
    return nil unless iso_duration
    
    # Parse ISO 8601 duration (e.g., "PT30M", "PT1H30M")
    match = iso_duration.match(/PT(?:(\d+)H)?(?:(\d+)M)?/)
    return nil unless match
    
    hours = match[1].to_i
    minutes = match[2].to_i
    
    (hours * 60) + minutes
  end
  
  def parse_servings(yield_value)
    return nil unless yield_value
    
    # Extract number from string like "4 servings" or "Makes 6"
    match = yield_value.to_s.match(/\d+/)
    match ? match[0].to_i : nil
  end
  
  def extract_instructions(instructions_data)
    return nil unless instructions_data
    
    if instructions_data.is_a?(String)
      return instructions_data
    elsif instructions_data.is_a?(Array)
      # Could be array of strings or array of HowToStep objects
      steps = instructions_data.map do |step|
        if step.is_a?(String)
          step
        elsif step.is_a?(Hash)
          step['text'] || step['name']
        end
      end
      return steps.compact.join("\n\n")
    end
    
    nil
  end
  
  def extract_image_url(image_data)
    return nil unless image_data
    
    if image_data.is_a?(String)
      return image_data
    elsif image_data.is_a?(Hash)
      return image_data['url']
    elsif image_data.is_a?(Array)
      return extract_image_url(image_data.first)
    end
    
    nil
  end
end
