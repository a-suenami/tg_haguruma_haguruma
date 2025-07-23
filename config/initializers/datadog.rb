# ==============================================================================
# config - initializers - datadog
# ==============================================================================
if Settings.datadog.enabled
  Datadog.configure do |c|
    c.tracing.instrument :rails, service_name: 'triple-rails'

    c.env = Rails.env
    c.tracing.analytics.enabled = true
    c.tracing.instrument :aws, analytics_enabled: true
    c.tracing.instrument :sidekiq, analytics_enabled: true
    c.tracing.instrument :faraday do |faraday|
      faraday.split_by_domain = true
    end
  end
end