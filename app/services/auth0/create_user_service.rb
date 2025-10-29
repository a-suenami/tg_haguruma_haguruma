# typed: strict
# frozen_string_literal: true

module Auth0
  # Create new Auth0 user with random password
  #
  # Usage:
  #   service = Auth0::CreateUserService.new(
  #     email: 'user@example.com',
  #     name: 'John Doe'
  #   )
  #   result = service.execute
  #
  #   if result.success?
  #     user = result.user # Auth0 user data with user_id
  #   else
  #     errors = result.errors
  #   end
  class CreateUserService < BaseService
    extend T::Sig

    sig { params(email: String, name: String).void }
    def initialize(email:, name:)
      @email = email
      @name = name
    end

    sig { returns(Result) }
    def execute
      # Generate strong random password for Auth0 user (with all character types)
      # Admin will reset via forgot password flow
      chars = [
        ('a'..'z').to_a,  # lowercase
        ('A'..'Z').to_a,  # uppercase
        ('0'..'9').to_a,  # digits
        ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '_', '+', '=', '[', ']', '{', '}'], # special chars
      ].flatten
      password = Array.new(32) { chars.sample(random: SecureRandom) }.join

      user_data = {
        email: @email,
        name: @name,
        password:,
        email_verified: true, # Skip auto verification email, admin will use Forgot Password flow
      }

      # create_user(connection, options)
      user = client.create_user('Username-Password-Authentication', user_data)
      Result.new(success: true, user:, errors: [])
    rescue StandardError => e
      Rails.logger.error("Auth0::CreateUserService error: #{e.message}")

      # Parse Auth0 error message if it's JSON
      error_message = begin
        error_data = JSON.parse(e.message)

        # Translate specific Auth0 errors to user-friendly messages
        case error_data['statusCode']
        when 409
          I18n.t('ruler_area.admins.errors.email_already_exists')
        else
          error_data['message'] || e.message
        end
      rescue JSON::ParserError
        e.message
      end

      Result.new(success: false, user: nil, errors: [error_message])
    end

    # Result object for service response
    class Result
      extend T::Sig

      sig { returns(T::Boolean) }
      attr_reader :success

      sig { returns(T.nilable(T::Hash[String, T.untyped])) }
      attr_reader :user

      sig { returns(T::Array[String]) }
      attr_reader :errors

      sig { params(success: T::Boolean, user: T.nilable(T::Hash[String, T.untyped]), errors: T::Array[String]).void }
      def initialize(success:, user:, errors:)
        @success = success
        @user = user
        @errors = errors
      end

      sig { returns(T::Boolean) }
      def success?
        @success
      end

      sig { returns(T::Boolean) }
      def failure?
        !@success
      end
    end
  end
end
