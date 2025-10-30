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
    rescue StandardError => e
      Rails.logger.error("Auth0::UpdatePasswordService error: #{e.message}")
      Mangrove::Result::Err.new(T.let([e.message], T::Array[String]))
    end
  end
end
