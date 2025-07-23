source "https://rubygems.org"

ruby "3.4.4"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use PostgreSQL as the database for Active Record
gem 'pg', '~> 1.5.4'
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# CORS support
gem 'rack-cors', '~> 2.0.1'

# Schema management
gem "ridgepole", "~> 2.0.0"

# Background processing
gem "sidekiq", "~> 7.2.4"
gem "sidekiq-status", "~> 3.0.3"

# Request storage
gem "request_store", "~> 1.5.1"
gem "request_store-sidekiq", "~> 0.1.0"

# Authorization
gem "pundit", "~> 2.3.1"

# Bulk insert
gem "activerecord-import", "~> 1.5.0"

# Template engine
gem "liquid", "~> 5.4.0"

# Connection pooling
gem "connection_pool", "~> 2.4.1"

# Redis
gem "redis", "~> 5.0.7"
gem "redis-client", "~> 0.19.0"
gem 'redlock', '~> 2.0.4'

# Error monitoring
gem "sentry-rails", "~> 5.13.0"
gem "sentry-ruby", "~> 5.13.0"
gem 'sentry-sidekiq', '~> 5.13.0'

# Typing
gem "sorbet-runtime", "~> 0.5.11048"
gem "mangrove", "~> 0.29.0"

# Utilities
gem 'pry', '~> 0.14.2'
gem 'config', '~> 5.0.0'
gem 'seed-fu', '~> 2.3.9'
gem 'ffaker', '~> 2.23.0'
gem 'jwt', '~> 2.7.1'
gem 'rbnacl', '~> 7.1', '>= 7.1.1'
gem 'rails-i18n', '~> 7.0.8'
gem 'enumerize', '~> 2.7.0'
gem 'yaml_vault', '~> 1.3.2'
gem 'faraday', '~> 2.7.11'
gem 'faraday-retry', '~> 2.2.0'
gem 'faraday-follow_redirects', '~> 0.3.0'
gem 'lograge', '~> 0.14.0'
gem 'jp_prefecture', '~> 1.1.1'
gem 'thor', '~> 1.3.0'
gem 'reserved_subdomain', '~> 0.0.4'
gem 'ddtrace', '~> 1.16.0'
gem 'phonelib', '~> 0.10.6'
gem 'ruby-jq', '~> 0.2.1'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Code style checking
  gem "rubocop", "~> 1.57.0"
  gem "rubocop-rails", "~> 2.22.0"
  gem "rubocop-rspec", "~> 2.25.0"
  gem "rubocop-sorbet", "~> 0.7.4", require: false

  # Typing tools
  gem "sorbet", "~> 0.5.11048"
  gem "tapioca", git: "https://github.com/twogate/tapioca", ref: "d0a8227"
  gem "spoom", "~> 1.2.4", require: false

  # Testing framework
  gem "rspec-rails", "~> 6.0.3"
  gem "rspec-sorbet", "~> 1.9.2"
  gem "factory_bot_rails", "~> 6.2.0"
  gem "database_cleaner", "~> 2.0.2"
  gem "simplecov", "~> 0.22.0", require: false
  gem "bullet", "~> 7.1.6"
  gem "webmock", "~> 3.19.1"

  # Development tools
  gem "pry-rails", "~> 0.3.9"
  gem "pry-byebug", "~> 3.10.1"
  # gem "annotate", "~> 3.2.0" # Not compatible with Rails 8.0 yet

  # Additional testing tools
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem 'rspec-request_describer', '~> 0.4.0'
  gem 'parallel_split_test', '~> 0.10.0'
  gem 'parallel_tests', '~> 4.3.0'
  gem 'bundler-audit', '~> 0.9.1'
  gem 'knapsack_pro', '~> 5.7.0'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Spring speeds up development by keeping your application running in the background
  gem 'spring', '~> 4.1.1'
  gem 'spring-watcher-listen', '~> 2.1.0'

  # Development tools
  gem 'rails-erd', '~> 1.7.2'
  gem 'ruby-lsp', '~> 0.23.20'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
