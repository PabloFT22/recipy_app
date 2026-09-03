# Rate limiting and brute-force protection.
#
# Without this, sign-in and password reset are unthrottled: an attacker can
# run credential-stuffing lists against the app as fast as the server answers.
class Rack::Attack
  # Counters live in Rails.cache by default. The test environment's null store
  # would silently make every throttle a no-op, so give tests a real one.
  self.cache.store = ActiveSupport::Cache::MemoryStore.new if Rails.env.test?

  ### Allow ###

  # Never throttle the platform health check or static assets.
  safelist("allow health check and assets") do |req|
    req.path == "/up" || req.path.start_with?("/assets")
  end

  ### Throttle ###

  # General ceiling: 300 requests per 5 minutes per IP. Generous enough that
  # normal browsing never notices, low enough to blunt scraping.
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  # Sign-in attempts by IP.
  throttle("logins/ip", limit: 10, period: 20.minutes) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end

  # Sign-in attempts by email, so an attacker spread across many IPs still
  # cannot grind a single account. Normalised so casing/whitespace can't
  # sidestep the counter.
  throttle("logins/email", limit: 10, period: 20.minutes) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params.dig("user", "email").to_s.downcase.strip.presence
    end
  end

  # Password reset requests — also an email-enumeration and mail-spend vector.
  throttle("password_resets/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/users/password" && req.post?
  end

  throttle("password_resets/email", limit: 5, period: 1.hour) do |req|
    if req.path == "/users/password" && req.post?
      req.params.dig("user", "email").to_s.downcase.strip.presence
    end
  end

  # Sign-ups, to slow bulk account creation.
  throttle("signups/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/users" && req.post?
  end

  # Recipe import makes the server fetch a URL the user chose, which is the
  # most expensive thing an anonymous-ish request can trigger. Keep it tight.
  throttle("imports/ip", limit: 10, period: 10.minutes) do |req|
    req.ip if req.path == "/recipes/import_from_url" && req.post?
  end

  ### Response ###

  self.throttled_responder = lambda do |request|
    retry_after = (request.env["rack.attack.match_data"] || {})[:period]
    [
      429,
      { "Content-Type" => "text/plain", "Retry-After" => retry_after.to_s },
      ["Too many requests. Please wait a few minutes and try again.\n"]
    ]
  end
end

# Log throttled requests so you can see attacks in the deployed logs.
ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _id, payload|
  req = payload[:request]
  Rails.logger.warn(
    "[rack-attack] throttled #{req.env['rack.attack.matched']} " \
    "ip=#{req.ip} path=#{req.path}"
  )
end
