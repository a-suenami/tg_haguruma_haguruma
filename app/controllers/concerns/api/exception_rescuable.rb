# typed: true
# frozen_string_literal: true

# ==============================================================================
# app - controllers - concerns - api - exception rescuable
# ==============================================================================
module Api
  module ExceptionRescuable
    extend T::Sig
    extend T::Helpers
    extend ActiveSupport::Concern

    include Api::JsonErrorResponse

    requires_ancestor { ActionController::API }

    included do
      T.bind(self, ActiveSupport::Rescuable::ClassMethods)

      rescue_from Exception, with: :handle_exception

      rescue_from ActiveRecord::RecordNotFound,       with: :handle_record_not_found
      rescue_from ActiveRecord::RecordInvalid,        with: :handle_record_invalid
      rescue_from ActiveRecord::RecordNotDestroyed,   with: :handle_record_not_destroyed
      rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

      # Content authorization errors
      rescue_from ContentAuthorizationQuery::ContentAuthorizationError, with: :handle_content_authorization_error

      # JWT verification errors
      rescue_from JWT::DecodeError,           with: :handle_jwt_decode_error
      rescue_from JWT::VerificationError,     with: :handle_jwt_verification_error
      rescue_from JWT::ExpiredSignature,      with: :handle_jwt_expired
      rescue_from JWT::InvalidIssuerError,    with: :handle_jwt_invalid_issuer
      rescue_from JWT::InvalidAudError,       with: :handle_jwt_invalid_audience
      rescue_from JWT::IncorrectAlgorithm,    with: :handle_jwt_incorrect_algorithm
    end

    sig { params(_exception: ActiveRecord::RecordNotFound).void }
    def handle_record_not_found(_exception)
      resource_not_found(
        code: :not_found,
        message: I18n.t('errors.messages.not_found'),
      )
    end

    sig { params(exception: ActiveRecord::RecordInvalid).void }
    def handle_record_invalid(exception)
      record = exception.record
      params = { messages: record.errors.as_json(full_messages: true), details: record.errors.details }

      invalid_request_error(
        code: :validation_error,
        message: I18n.t('errors.messages.error_occurred'),
        params:,
      )
    end

    sig { params(exception: ActiveRecord::RecordNotDestroyed).void }
    def handle_record_not_destroyed(exception)
      record = exception.record
      params = { messages: record&.errors&.as_json(full_messages: true), details: record&.errors&.details }

      invalid_request_error(
        code: :deletion_error,
        message: I18n.t('errors.messages.error_occurred'),
        params:,
      )
    end

    sig { params(exception: ActionController::ParameterMissing).void }
    def handle_parameter_missing(exception)
      invalid_request_error(
        code: :invalid_parameter,
        message: I18n.t('errors.messages.parameter_missing'),
        params: {
          missing_parameter: exception.param,
        },
      )
    end

    # Content authorization error handler
    sig { params(_exception: ContentAuthorizationQuery::ContentAuthorizationError).void }
    def handle_content_authorization_error(_exception)
      forbidden(
        message: I18n.t('errors.messages.content_authorization_denied', default: 'Access to this content is not authorized'),
      )
    end

    # JWT error handlers
    sig { params(_exception: JWT::DecodeError).void }
    def handle_jwt_decode_error(_exception)
      authentication_error(
        code: :invalid_token,
        message: I18n.t('errors.messages.invalid_token', default: 'Invalid token'),
      )
    end

    sig { params(_exception: JWT::VerificationError).void }
    def handle_jwt_verification_error(_exception)
      authentication_error(
        code: :token_verification_failed,
        message: I18n.t('errors.messages.token_verification_failed', default: 'Token verification failed'),
      )
    end

    sig { params(_exception: JWT::ExpiredSignature).void }
    def handle_jwt_expired(_exception)
      authentication_error(
        code: :token_expired,
        message: I18n.t('errors.messages.token_expired', default: 'Token has expired'),
      )
    end

    sig { params(_exception: JWT::InvalidIssuerError).void }
    def handle_jwt_invalid_issuer(_exception)
      authentication_error(
        code: :invalid_issuer,
        message: I18n.t('errors.messages.invalid_issuer', default: 'Invalid token issuer'),
      )
    end

    sig { params(_exception: JWT::InvalidAudError).void }
    def handle_jwt_invalid_audience(_exception)
      authentication_error(
        code: :invalid_audience,
        message: I18n.t('errors.messages.invalid_audience', default: 'Invalid token audience'),
      )
    end

    sig { params(_exception: JWT::IncorrectAlgorithm).void }
    def handle_jwt_incorrect_algorithm(_exception)
      authentication_error(
        code: :incorrect_algorithm,
        message: I18n.t('errors.messages.incorrect_algorithm', default: 'Incorrect token algorithm'),
      )
    end

    # Generic exception handler
    sig { params(exception: Exception).void }
    def handle_exception(exception)
      Rails.logger.error("Unhandled exception: #{exception.class} - #{exception.message}")
      Rails.logger.error(exception.backtrace&.join("\n"))

      # In development/test, re-raise to see the full stack trace
      raise if Rails.env.development? || Rails.env.test?

      # In production, log to Sentry if available and return generic error
      if defined?(Sentry)
        Sentry.capture_exception(exception)
      end

      internal_server_error(
        message: I18n.t('errors.messages.something_went_wrong'),
      )
    end
  end
end
