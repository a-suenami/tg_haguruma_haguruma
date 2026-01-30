Sentry.init do |config|
  config.dsn = ENV.fetch('SENTRY_DSN', nil)
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 0.1
  # or
  config.traces_sampler = ->(_context) do
    true
  end

  # Set profiles_sample_rate to profile 100%
  # of sampled transactions.
  # We recommend adjusting this value in production.
  config.profiles_sample_rate = 0.1

  # Disable sending PII by default
  config.send_default_pii = false

  # Scrub sensitive data from error messages before sending to Sentry
  # Uses Rails' ParameterFilter for consistent filtering with logs
  config.before_send = ->(event, _hint) { SentryScrubber.scrub(event) }
end

# Scrubber module using Rails' ParameterFilter for consistent filtering
module SentryScrubber
  # Additional patterns for credentials that might appear in error messages
  # These patterns catch credentials in command output, URIs, etc.
  CREDENTIAL_PATTERNS = [
    # Database URLs with credentials: postgresql://user:pass@host
    %r{(postgresql|postgres|mysql|mysql2)://[^:]+:[^@]+@[^\s]+}i,
    # Generic URI with credentials: scheme://user:pass@host
    %r{://[^/:]+:[^@]+@[^\s]+}i,
  ].freeze

  class << self
    def scrub(event)
      return event unless event

      # Scrub exception messages (most important for this issue)
      scrub_exceptions(event)

      # Scrub other event data using Rails' ParameterFilter
      scrub_with_parameter_filter(event)

      event
    end

    private

    def scrub_exceptions(event)
      return unless event.exception&.values

      event.exception.values.each do |exception|
        next unless exception.value

        exception.value = scrub_credential_patterns(exception.value)
      end
    end

    def scrub_credential_patterns(str)
      return str unless str.is_a?(String)

      result = str.dup
      CREDENTIAL_PATTERNS.each do |pattern|
        result.gsub!(pattern) { |match| mask_uri_credentials(match) }
      end
      result
    end

    def mask_uri_credentials(uri_str)
      uri_str.gsub(%r{://([^/:]+):([^@]+)@}, '://[FILTERED]:[FILTERED]@')
    end

    def scrub_with_parameter_filter(event)
      filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)

      # Scrub extra context
      event.extra = filter.filter(event.extra) if event.extra.is_a?(Hash)

      # Scrub tags
      event.tags = filter.filter(event.tags) if event.tags.is_a?(Hash)

      # Scrub user context
      event.user = filter.filter(event.user) if event.user.is_a?(Hash)

      # Scrub request data
      if event.request.is_a?(Hash)
        event.request = filter.filter(event.request)
      end

      # Scrub breadcrumb data
      event.breadcrumbs&.each do |breadcrumb|
        breadcrumb.data = filter.filter(breadcrumb.data) if breadcrumb.data.is_a?(Hash)
      end
    end
  end
end
