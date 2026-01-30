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

  # Scrub sensitive data from error messages before sending to Sentry
  config.before_send = lambda do |event, _hint|
    SentryScrubber.scrub_event(event)
  end
end

# Scrubber to remove sensitive data from Sentry events
module SentryScrubber
  SENSITIVE_PATTERNS = [
    # Database credentials in various formats
    /password:\s*\S+/i,
    /password=\S+/i,
    # Database URLs with credentials
    %r{(postgresql|postgres|mysql|mysql2)://[^:]+:[^@]+@}i,
    # AWS credentials
    /aws_access_key_id[=:]\s*\S+/i,
    /aws_secret_access_key[=:]\s*\S+/i,
    # API keys and tokens
    /api[_-]?key[=:]\s*\S+/i,
    /secret[_-]?key[=:]\s*\S+/i,
    /auth[_-]?token[=:]\s*\S+/i,
    /bearer\s+\S+/i,
    # Generic secrets
    /secret[=:]\s*\S+/i,
    /token[=:]\s*\S+/i,
    # Host with credentials
    %r{://[^:]+:[^@]+@[^/]+}i,
  ].freeze

  REPLACEMENT = '[FILTERED]'

  class << self
    def scrub_event(event)
      return event unless event

      # Scrub exception messages
      if event.exception&.values
        event.exception.values.each do |exception|
          exception.value = scrub_string(exception.value) if exception.value
        end
      end

      # Scrub message
      event.message = scrub_string(event.message) if event.message

      # Scrub breadcrumbs
      event.breadcrumbs&.each do |breadcrumb|
        breadcrumb.message = scrub_string(breadcrumb.message) if breadcrumb.message
        scrub_hash(breadcrumb.data) if breadcrumb.data
      end

      # Scrub extra context
      scrub_hash(event.extra) if event.extra

      # Scrub tags
      scrub_hash(event.tags) if event.tags

      event
    end

    private

    def scrub_string(str)
      return str unless str.is_a?(String)

      result = str.dup
      SENSITIVE_PATTERNS.each do |pattern|
        result.gsub!(pattern) do |match|
          # Keep the key part, replace only the value
          if match.include?('=')
            key = match.split('=').first
            "#{key}=#{REPLACEMENT}"
          elsif match.include?(':')
            key = match.split(':').first
            "#{key}: #{REPLACEMENT}"
          elsif match.match?(%r{://})
            # For URLs, replace the credentials part
            match.gsub(%r{://[^:]+:[^@]+@}, "://#{REPLACEMENT}:#{REPLACEMENT}@")
          else
            REPLACEMENT
          end
        end
      end
      result
    end

    def scrub_hash(hash)
      return unless hash.is_a?(Hash)

      hash.each do |key, value|
        case value
        when String
          hash[key] = scrub_string(value)
        when Hash
          scrub_hash(value)
        when Array
          value.each_with_index do |item, index|
            case item
            when String
              value[index] = scrub_string(item)
            when Hash
              scrub_hash(item)
            end
          end
        end
      end
    end
  end
end
