# typed: strict
# frozen_string_literal: true

module Auth0
  # Update user password in Auth0
  class UpdatePasswordService < BaseService
    extend T::Sig

    sig { params(uid: String, password: String).void }
    def initialize(uid:, password:)
      @uid = uid
      @password = password
    end

    sig { returns(Result) }
    def execute
      begin
        client.patch_user(@uid, { password: @password })
        Result.new(success: true, errors: [])
      rescue StandardError => e
        Rails.logger.error("Auth0::UpdatePasswordService error: #{e.message}")
        Result.new(success: false, errors: [e.message])
      end
    end

    # Result object
    class Result
      extend T::Sig

      sig { returns(T::Boolean) }
      attr_reader :success

      sig { returns(T::Array[String]) }
      attr_reader :errors

      sig { params(success: T::Boolean, errors: T::Array[String]).void }
      def initialize(success:, errors:)
        @success = success
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
