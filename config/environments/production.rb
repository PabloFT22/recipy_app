require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  # config.public_file_server.enabled = false

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  # Object storage. The container filesystem is ephemeral, so uploads written
  # to disk vanish on every deploy — :s3 (see config/storage.yml) is required
  # in production. It falls back to :local only so the image can still boot
  # with storage unconfigured, which you should never do with real users.
  config.active_storage.service = ENV["AWS_BUCKET"].present? ? :s3 : :local

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # "info" includes generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "recipy_app_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # ── Host authorization ───────────────────────────────────────────
  # Blocks Host-header spoofing and DNS rebinding. APP_HOST is your own
  # domain; the fly.dev subdomain stays allowed so the app is reachable
  # before DNS is pointed at it.
  config.hosts << ENV["APP_HOST"] if ENV["APP_HOST"].present?
  config.hosts << /.*\.fly\.dev\z/
  # The platform health check hits /up without a public Host header.
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # ── Mail ─────────────────────────────────────────────────────────
  # Password resets are the only mail this app sends, and they are useless
  # if the links in them point at the wrong host.
  mailer_host = ENV.fetch("APP_HOST", "localhost:3000")
  config.action_mailer.default_url_options = { host: mailer_host, protocol: "https" }
  config.action_mailer.asset_host = "https://#{mailer_host}"

  # Raise rather than silently swallow delivery failures, so a broken SMTP
  # config surfaces in the error tracker instead of stranding users who are
  # waiting on a reset email.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              ENV.fetch("SMTP_ADDRESS", "smtp.resend.com"),
    port:                 ENV.fetch("SMTP_PORT", 587).to_i,
    user_name:            ENV["SMTP_USERNAME"],
    password:             ENV["SMTP_PASSWORD"],
    authentication:       :plain,
    enable_starttls_auto: true
  }

  # ── Transport security ───────────────────────────────────────────
  # force_ssl (above) redirects http→https and marks cookies secure. This
  # pins HSTS to a year across subdomains.
  config.ssl_options = {
    hsts: { expires: 1.year, subdomains: true, preload: false }
  }

  # Fly terminates TLS at its edge and forwards over plain HTTP, so Rails has
  # to be told the original request was secure — otherwise force_ssl sees http
  # and redirect-loops.
  config.assume_ssl = true
end
