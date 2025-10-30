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
  #   if result.is_a?(Mangrove::Result::Ok)
  #     user = result.unwrap # Auth0 user data with user_id
  #   else
  #     errors = result.unwrap_err
  #   end
  class CreateUserService < BaseService
    extend T::Sig

    sig { params(email: String, name: String).void }
    def initialize(email:, name:)
      @email = email
      @name = name
    end

    sig { returns(Mangrove::Result[T::Hash[String, T.untyped], T::Array[String]]) }
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
      Mangrove::Result::Ok.new(user)
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

      Mangrove::Result::Err.new(T.let([error_message], T::Array[String]))
    end
  end
end
