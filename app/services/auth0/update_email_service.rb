# typed: strict
# frozen_string_literal: true

module Auth0
  # Update user email in Auth0
  #
  # Usage:
  #   service = Auth0::UpdateEmailService.new(uid: 'auth0|123', email: 'new@example.com')
  #   result = service.execute
  #
  #   if result.is_a?(Mangrove::Result::Ok)
  #     # Success
  #   else
  #     errors = result.err_inner
  #   end
  class UpdateEmailService < BaseService
    extend T::Sig

    sig { params(uid: String, email: String).void }
    def initialize(uid:, email:)
      @uid = uid
      @email = email
    end

    sig { returns(Mangrove::Result[T::Boolean, T::Array[String]]) }
    def execute
      # Update email and name (name should match email)
      client.patch_user(@uid, { email: @email, name: @email })
      Mangrove::Result::Ok.new(T.let(true, T::Boolean))
    rescue StandardError => e
      Rails.logger.error("Auth0::UpdateEmailService error: #{e.message}")
      error_message = parse_auth0_error(e.message)
      Mangrove::Result::Err.new(T.let([error_message], T::Array[String]))
    end

    private

    sig { params(error_string: String).returns(String) }
    def parse_auth0_error(error_string)
      # Try to parse JSON error from Auth0
      json_error = JSON.parse(error_string)
      message = json_error['message'] || json_error['error_description']

      # Map common Auth0 errors to user-friendly messages
      case json_error['errorCode']
      when 'auth0_idp_error'
        if message&.include?('already exists')
          I18n.t('ruler_area.profiles.errors.email_already_exists')
        else
          message
        end
      else
        message || error_string
      end
    rescue JSON::ParserError
      # If not JSON, return as is
      error_string
    end

  end
end
