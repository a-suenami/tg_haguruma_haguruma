# typed: false

# ==============================================================================
# config - initializers - cors
# ==============================================================================
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow_origins = if Rails.env.production?
    [
      %r{^(http|https)://localhost$},
      %r{^(http|https)://localhost:\d{4,5}$},
    ].map(&:freeze).freeze
  else
    [
      %r{^(http|https)://localhost$},
      %r{^(http|https)://localhost:\d{4,5}$},
      %r{^https://.+\.ticket.app-staging.t-riple.com$},
      %r{^https://.+\.ticket.app-qa.t-riple.com$},
      %r{^https://\w+\.ngrok\.app$},
    ].map(&:freeze).freeze
  end

  allow do
    # rubocop:disable Security/Eval
    origins allow_origins + eval(ENV['ALLOW_ORIGINS'] || '[]')
    # rubocop:enable Security/Eval

    resource '/api/*',
      headers: :any,
      expose: ['Total', 'Per-Page'],
      credentials: false,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end