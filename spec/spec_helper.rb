# typed: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is not test
abort('The Rails environment is running in not test mode!') unless Rails.env.test?

require 'rspec/rails'
require 'rspec/sorbet'
require "#{Rails.root}/app/lib/pretty_print.rb"
require 'knapsack_pro'
require 'sidekiq/testing'

extend T::Sig # rubocop:disable Style/MixinUsage

Sidekiq::Testing.disable!

RSpec::Sorbet.allow_doubles! # allow doubles to be used without breaking type checking

Dir[Rails.root.join('spec', 'helpers', '**', '*.rb')].each { |f| require f }

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
  config.fixture_path = "#{Rails.root}/spec/fixtures"
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)

    unless ENV['PARALLEL_SPLIT_TEST']
      # CI などで並列実行する際は事前に `bundle exec thor dynamodb:migrate` を実行する
      # Execute `bundle exec thor dynamodb:migrate` before parallel execution for CI etc.

      DynamoDBHelper.delete_dynamodb_table
      DynamoDBHelper.migrate_dynamodb
    end

    DynamoDBHelper.seed_dynamodb(:kenshiyonezu)

    RedisClient.define_singleton_method(:pool) do
      # 並列にテストを走らせたときにそれぞれ異なる db を利用する（+ 3 は適当）
      # Use a different db for each when running tests in parallel (+ 3 is approx num)
      return @pool if @pool

      timeout = 1 # in seconds
      size = ENV.fetch('RAILS_MAX_THREADS', 10).to_i

      redis_config = RedisClient.config(url: Settings.redis.url, db: ENV['TEST_ENV_NUMBER'].to_i + 3)
      @pool = redis_config.new_pool(timeout:, size:)
    end
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before do
    RedisClient.pool.call('flushdb')
    RequestStore.clear!
  end

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

  # cache store を option で切り替える
  config.around do |example|
    if example.metadata[:cache_store].present?
      default_cache_store = Rails.cache
      option = example.metadata[:cache_store_option] || {}
      # 並列にテストを走らせたときにそれぞれ異なる db を利用する（+ 3 は適当）
      option[:db] = ENV['TEST_ENV_NUMBER'].to_i + 3 if example.metadata[:cache_store] == :redis_cache_store

      cache_store = ActiveSupport::Cache.lookup_store(example.metadata[:cache_store], option)
      Rails.cache = cache_store

      example.run

      Rails.cache.clear rescue nil
      Rails.cache = default_cache_store
    else
      example.run
    end
  end

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


  config.include RSpec::RequestDescriber, type: :request
  config.include RequestHelper, type: :request
  config.include FactoryBot::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers
  # config.include DynamoDBHelpers
end

RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec::Matchers.define :eq_status do
  T.bind(self, RSpec::Matchers::DSL::Macros)

  match do |_actual|
    T.bind(self, RSpec::Matchers::DSL::Matcher)

    matcher = RSpec::Matchers::BuiltIn::Eq.new(expected)
    matcher.matches?(actual)
  end

  failure_message do |actual|
    T.bind(self, RSpec::Matchers::DSL::Matcher)

    response = T.let(T.unsafe(self).response, ActionDispatch::TestResponse)

    # actual は期待している HTTP response code (integer)
    if actual >= 400
      <<~MESSAGE
        expected: #{expected}
             got: #{actual}

        #{JSON.pretty_generate(JSON.parse(response.body))}
      MESSAGE
    else
      <<~MESSAGE
        expected: #{expected}
             got: #{actual}
      MESSAGE
    end
  end
end

sig { params(expected: T::Hash[T.untyped, T.untyped], actual: T::Hash[T.untyped, T.untyped]).returns(String) }
def inspect_differences(expected, actual)
  messages = collect_diff([], expected, actual, [])
  messages.join("\n")
end

sig { params(ancestor_keys: T::Array[String], expected_hash: T::Hash[T.untyped, T.untyped], actual: T::Hash[T.untyped, T.untyped], messages: T::Array[String]).returns(T::Array[String]) }
def collect_diff(ancestor_keys, expected_hash, actual, messages)
  expected_keys = T.let(expected_hash.keys.map(&:to_sym), T::Array[Symbol])
  actual_keys = T.let(actual.keys.map(&:to_sym), T::Array[Symbol])

  if expected_keys.sort == actual_keys.sort
    expected_hash.each do |key, _expected|
      if _expected.respond_to?(:matches?)
        if _expected.is_a?(RSpec::Matchers::DSL::Matcher)
          case _expected.name
          when :match_inner
            collect_diff(ancestor_keys + [key], _expected.expected, actual[key], messages)
          when :match_inner_any
            messages_array = []
            T.let(actual[key].presence || [{}], T::Array[T.untyped]).each do |item|
              messages_array << collect_diff(ancestor_keys + [key], _expected.expected, item, [])
            end
            if messages_array.all?(&:present?) # いずれか一つも match しなかった場合のみ failure message を表示する
              messages += messages_array.flatten
            end
          else
            raise 'unexpected matcher'
          end
        else
          # _expected が be_present などの built in matcher の場合
          messages << "#{(ancestor_keys + [key]).join('.')}:\n  #{_expected.failure_message}" unless _expected.matches?(actual[key])
        end
      else
        # _expected が matcher でない場合（String, Integer, Hash など primitive な場合）
        if _expected != actual[key]
          _expected = '`nil`' if _expected.nil?
          messages << "#{(ancestor_keys + [key]).join('.')}:\n  expected #{_expected}, but got #{actual[key]}"
        end
      end
    end
  else
    if expected_keys - actual_keys != []
      keys = (expected_keys - actual_keys).map { "#{ancestor_keys.join('.')}.#{_1}" }
      messages << "Missing keys:\n  #{keys.join(', ')}"
    end
    if actual_keys - expected_keys != []
      keys = (actual_keys - expected_keys).map { "#{ancestor_keys.join('.')}.#{_1}" }
      messages << "Extra keys:\n  #{keys.join(', ')}"
    end
  end

  messages
end

RSpec::Matchers.define :match_deep do |expected|
  T.bind(self, RSpec::Matchers::DSL::Macros)

  match do |_actual|
    T.bind(self, RSpec::Matchers::DSL::Matcher)

    begin
      matcher = RSpec::Matchers::BuiltIn::Match.new(expected)
      if matcher.matches?(actual)
        true
      else
        @failure_message = inspect_differences(expected, actual)
        @failure_message = matcher.failure_message if @failure_message.blank?
        false
      end
    rescue => e
      @failure_message = inspect_differences(expected, actual)
      @failure_message = e.message if @failure_message.blank?
      false
    end
  end

  failure_message do |_actual|
    @failure_message
  end
end

RSpec::Matchers.define :match_deep_any do |expected|
  T.bind(self, RSpec::Matchers::DSL::Macros)
  match do |actual|
    T.bind(self, RSpec::Matchers::DSL::Matcher)

    if actual.is_a? Array
      actual.any? do |item|
        begin
          matcher = RSpec::Matchers::BuiltIn::Match.new(expected)
          if matcher.matches?(item)
            true
          else
            @failure_message = actual.map do |actual_item|
              inspect_differences(expected, actual_item)
            end.join("\n")
            @failure_message = matcher.failure_message if @failure_message.blank?
            false
          end
        rescue => e
          @failure_message = actual.map do |actual_item|
            inspect_differences(expected, actual_item)
          end.join("\n")
          @failure_message = e.message if @failure_message.blank?
          false
        end
      end
    else
      raise 'actual must be an array'
    end
  end

  failure_message do |_actual|
    @failure_message
  end
end

# match_deep, match_deep_any の中でのみ使用する
# match しなかったときに failure_message ではなく例外が発生するため単体では使わない
RSpec::Matchers.define :match_inner do |expected|
  T.bind(self, RSpec::Matchers::DSL::Macros)

  match do |actual|
    T.bind(self, RSpec::Matchers::DSL::Matcher)

    begin
      expect(actual).to match(expected)
    rescue RSpec::Expectations::ExpectationNotMetError => e
      raise e.message
    end
  end
end

# match_deep, match_deep_any の中でのみ使用する
# match しなかったときに failure_message ではなく例外が発生するため単体では使わない
RSpec::Matchers.define :match_inner_any do |expected|
  T.bind(self, RSpec::Matchers::DSL::Macros)

  match do |actual|
    T.bind(self, RSpec::Matchers::DSL::Matcher)

    if actual.is_a? Array
      exception = T.let(nil, T.nilable(RSpec::Expectations::ExpectationNotMetError))
      actual = [{}] if actual == []

      matched = actual.any? do |item|
        begin
          expect(item).to match(expected)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          exception = e
          false
        end
      end

      unless matched
        raise T.must(exception).message
      end

      matched
    else
      raise 'actual must be an array'
    end
  end
end

RSpec::Matchers.define :match_schema do |expected|
  T.bind(self, RSpec::Matchers::DSL::Macros)
  match do |actual|
    T.bind(self, RSpec::Matchers::DSL::Matcher)

    if actual.is_a? Array
      matched = actual.any? do |item|
        expect(item).to match_schema(expected)
      end

      return false unless matched
    elsif actual.is_a? Hash
      matched = expected.all? do |key, value|
        if value.is_a?(Array)
          next false unless actual[key].is_a?(Array)

          expect(actual[key]).to match_schema(value[0])
        elsif value.is_a?(Hash)
          next false unless actual[key].is_a?(Hash)

          expect(actual[key]).to match_schema(value)
        else
          expect(actual[key]).to match_schema(value)
        end
      end

      return false unless matched
    else
      if RSpec::Matchers::BuiltIn::Match.new(expected).matches?(actual)
        true
      else
        raise "expected: #{expected}, but got: #{actual}"
      end
    end

    true
  end

  failure_message do |actual|
    "expected: #{expected}\ngot: #{actual}"
  end
end

KnapsackPro::Adapters::RSpecAdapter.bind

Settings.reload!