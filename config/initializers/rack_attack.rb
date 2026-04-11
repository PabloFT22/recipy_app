Rack::Attack.throttle('login attempts', limit: 5, period: 20) do |req|
  req.ip if req.path == '/users/sign_in' && req.post?
end

Rack::Attack.throttle('recipe import', limit: 10, period: 60) do |req|
  req.ip if req.path.include?('import_from_url') && req.post?
end

Rack::Attack.throttle('api requests', limit: 100, period: 60) do |req|
  req.ip if req.path.start_with?('/recipes') || req.path.start_with?('/grocery_lists')
end

Rack::Attack.blocklisted_responder = lambda do |env|
  [429, { 'Content-Type' => 'text/plain' }, ["Rate limit exceeded. Please try again later.\n"]]
end
