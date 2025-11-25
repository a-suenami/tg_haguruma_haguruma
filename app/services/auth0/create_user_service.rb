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
      }

      # create_user(connection, options)
      user = client.create_user('Username-Password-Authentication', user_data)
      Mangrove::Result::Ok.new(user)
    rescue Auth0::HTTPError => e
      Rails.logger.error("Auth0::CreateUserService error: HTTP #{e.http_code} - #{e.message}")

      # Map Auth0 API HTTP status codes to user-friendly messages
      error_message = case e.http_code
      when 409 # Conflict - Email already exists in Auth0
        I18n.t('ruler_area.admins.errors.email_already_exists')
      when 400 # Bad Request - Invalid parameters
        # Parse error message from Auth0 response
        begin
          error_data = JSON.parse(e.message)
          error_data['message'] || e.message
        rescue JSON::ParserError
          e.message
        end
      else
        # For other HTTP errors (401, 404, 429, 500, etc.), use raw message
        e.message
      end

      Mangrove::Result::Err.new(T.let([error_message], T::Array[String]))
    end
  end
end
