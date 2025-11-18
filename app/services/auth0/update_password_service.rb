# typed: strict
# frozen_string_literal: true

module Auth0
  # Update user password in Auth0
  #
  # Usage:
  #   service = Auth0::UpdatePasswordService.new(uid: 'auth0|123', password: 'newpassword')
  #   result = service.execute
  #
  #   if result.is_a?(Mangrove::Result::Ok)
  #     # Success
  #   else
  #     errors = result.err_inner
  #   end
  class UpdatePasswordService < BaseService
    extend T::Sig

    sig { params(uid: String, password: String).void }
    def initialize(uid:, password:)
      @uid = uid
      @password = password
    end

    sig { returns(Mangrove::Result[T::Boolean, T::Array[String]]) }
    def execute
      # Update password only
      client.patch_user(@uid, { password: @password })
      Mangrove::Result::Ok.new(T.let(true, T::Boolean))
    rescue Auth0::HTTPError => e
      Rails.logger.error("Auth0::UpdatePasswordService error: HTTP #{e.http_code} - #{e.message}")

      # Map Auth0 API HTTP status codes to user-friendly messages
      error_message = case e.http_code
      when 400 # Bad Request - Password doesn't meet requirements
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
