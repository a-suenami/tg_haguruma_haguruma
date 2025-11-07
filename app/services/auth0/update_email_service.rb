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
    rescue Auth0::HTTPError => e
      Rails.logger.error("Auth0::UpdateEmailService error: HTTP #{e.http_code} - #{e.message}")

      # Map Auth0 API HTTP status codes to user-friendly messages
      error_message = case e.http_code
      when 400 # Bad Request - Could be duplicate email or invalid format
        # Parse error message from Auth0 response
        begin
          error_data = JSON.parse(e.message)
          error_code = error_data['errorCode']
          auth0_message = error_data['message'] || ''

          # Check error code for duplicate email
          if error_code == 'auth0_idp_error'
            I18n.t('ruler_area.profiles.errors.email_already_exists')
          else
            # Other validation errors (invalid format, etc)
            auth0_message.presence || e.message
          end
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
