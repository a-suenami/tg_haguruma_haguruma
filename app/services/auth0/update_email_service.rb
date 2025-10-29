# typed: strict
# frozen_string_literal: true

module Auth0
  # Update user email in Auth0
  class UpdateEmailService < BaseService
    extend T::Sig

    sig { params(uid: String, email: String).void }
    def initialize(uid:, email:)
      @uid = uid
      @email = email
    end

    sig { returns(Result) }
    def execute
      client.patch_user(@uid, { email: @email, name: @email })
      Result.new(success: true, errors: [])
    rescue StandardError => e
      Rails.logger.error("Auth0::UpdateEmailService error: #{e.message}")
      error_message = parse_auth0_error(e.message)
      Result.new(success: false, errors: [error_message])
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
