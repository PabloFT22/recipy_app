class RecipeScraperService
  attr_reader :url, :errors
  
  def initialize(url)
    @url = url
    @errors = []
  end
  
  def scrape
    return nil unless url.present?

    unless valid_url?(url)
      @errors << "Invalid URL: must be a public http(s) URL"
      return nil
    end

    begin
      response = HTTParty.get(url, timeout: 10)
      
      unless response.success?
        @errors << "Failed to fetch URL: #{response.code}"
        return nil
      end
      
      doc = Nokogiri::HTML(response.body)
      
      recipe_data = extract_json_ld(doc)
      return recipe_data if recipe_data
      
      extract_from_meta_and_selectors(doc)
      
    rescue HTTParty::Error, Timeout::Error => e
      @errors << "Network error: #{e.message}"
      nil
    rescue StandardError => e
      @errors << "Parsing error: #{e.message}"
      nil
    end
  end
  
  private

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    false
  end

  def extract_json_ld(doc)
    json_ld_scripts = doc.css('script[type="application/ld+json"]')
    
    json_ld_scripts.each do |script|
      begin
        data = JSON.parse(script.content)
        items = data.is_a?(Array) ? data : [data]
        recipe = items.find { |item| item['@type'] == 'Recipe' }
        
        if recipe
          return {
            title: recipe['name'],
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
