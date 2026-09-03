# Content Security Policy.
#
# The layout loads Inter and Fraunces from Google Fonts, so fonts.googleapis.com
# (the stylesheet) and fonts.gstatic.com (the font files) have to be allowed.
# Everything else is same-origin only.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri    :self
    policy.font_src    :self, :data, "https://fonts.gstatic.com"
    policy.img_src     :self, :data, :blob, :https
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self, "https://fonts.googleapis.com"
    policy.connect_src :self
    policy.form_action :self
    # Stops the app being framed — clickjacking protection, and the modern
    # replacement for X-Frame-Options.
    policy.frame_ancestors :none

    # Report violations to your error tracker once you have one wired up:
    # policy.report_uri "https://your-sentry-ingest/csp-report"
  end

  # A fresh random nonce per request. (Deriving it from the session id is
  # empty on a visitor's first request, which would block everything below.)
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

  # Importmap needs two inline <script> tags (the map itself and the module
  # entry point); javascript_importmap_tags stamps them with this nonce. Turbo
  # reads the same nonce from csp_meta_tag for the inline styles it injects.
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Start in report-only for the first deploy so a mistake here cannot take the
  # site down: violations are logged by the browser but nothing is blocked.
  # Watch the browser console, then set this to false to start enforcing.
  config.content_security_policy_report_only =
    ENV.fetch("CSP_ENFORCE", "false") != "true"
end
