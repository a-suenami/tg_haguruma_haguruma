# typed: false

# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

# This file is loaded before Rails

RSpec.configure do |config|
  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true unless meta.key?(:aggregate_failures)
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.profile_examples = 10
  # Rails-specific configuration moved to rails_helper.rb

  # Database and Redis configuration moved to rails_helper.rb

  # Temporary disable bullet
  # if Bullet.enable?
  #   config.before do
  #     Bullet.start_request
  #   end

  #   config.after do
  #     Bullet.perform_out_of_channel_notifications if Bullet.notification?
  #     Bullet.end_request
  #   end
  # end

  # Cache store configuration moved to rails_helper.rb

  # locale を option で切り替える
  config.around do |example|
    if example.metadata[:locale]
      I18n.with_locale(example.metadata[:locale]) do
        example.run
      end
    else
      example.run
    end
  end


  # Module inclusions moved to rails_helper.rb
end

# Custom matchers and configuration requiring Rails moved to rails_helper.rb
