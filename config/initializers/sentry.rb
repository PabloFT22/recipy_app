# Error monitoring (DEPLOYING.md step 12). Does nothing unless SENTRY_DSN is
# set, so development and test never report anywhere.
if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.environment = Rails.env
    config.release = ENV["FLY_MACHINE_VERSION"].presence

    # Rails' filter_parameter_logging list (passwords, tokens…) applies to
    # what Sentry sees too.
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    config.before_send = ->(event, _hint) { filter.filter(event.to_hash) }

    # Errors only. No user emails/IPs, no performance tracing — keeps the
    # free tier roomy and the data footprint small.
    config.send_default_pii = false
    config.traces_sample_rate = 0.0

    # These are user mistakes, not application errors.
    config.excluded_exceptions += %w[
      ActionController::RoutingError
      ActiveRecord::RecordNotFound
      ActionController::InvalidAuthenticityToken
    ]
  end
end
