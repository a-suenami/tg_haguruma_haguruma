# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - controllers - concerns - api - json error response
# ==============================================================================
module Api
  module JsonErrorResponse
    extend T::Sig
    extend T::Helpers

    requires_ancestor { Kernel }
    requires_ancestor { ActionController::API }

    sig {
      params(
        message: String, type: Symbol, code: T.nilable(T.any(String, Symbol)), params: T.nilable(T::Hash[Symbol, T.untyped]),
      ).returns(T::Hash[Symbol, T.untyped])
    }
    def generate_json(message:, type:, code: nil, params: nil)
      error = {}
      error[:type] = type
      error[:code] = code unless code.nil?
      error[:message] = message
      error[:params] = params unless params.nil?

      error
    end

    # HTTP 400
    sig {
      params(message: String, code: T.nilable(T.any(String, Symbol)), params: T.nilable(T::Hash[Symbol, T.untyped]), object: T.nilable(ApplicationSerializer))
        .void
    }
    def invalid_request_error(message:, code: nil, params: nil, object: nil)
      error = generate_json(message:, type: :invalid_request_error, code:, params:)

      render json: { error: }.merge(object&.as_json || {}), status: :bad_request
    end

    # HTTP 401
    sig { params(code: Symbol, message: String).void }
    def authentication_error(code:, message:)
      error = generate_json(message:, type: :authentication_error, code:)

      render json: { error: }, status: :unauthorized
    end

    # HTTP 403
    sig { params(message: String, code: T.nilable(String)).void }
    def forbidden(message:, code: nil)
      error = generate_json(message:, type: :forbidden, code:)

      render json: { error: }, status: :forbidden
    end

    # HTTP 404
    sig { params(message: String, code: Symbol).void }
    def resource_not_found(message:, code:)
      error = generate_json(message:, type: :resource_not_found, code:)

      render json: { error: }, status: :not_found
    end

    # HTTP 429
    sig { params(message: String).void }
    def too_many_requests(message:)
      error = generate_json(message:, type: :too_many_requests)

      render json: { error: }, status: :too_many_requests
    end

    # HTTP 500
    sig { params(message: T.nilable(String), code: T.nilable(Symbol)).void }
    def internal_server_error(message: nil, code: nil)
      message ||= I18n.t('errors.messages.something_went_wrong')
      error = generate_json(code:, message:, type: :internal_server_error)

      render json: { error: }, status: :internal_server_error
    end

    # HTTP 502
    sig { params(message: T.nilable(String), code: T.nilable(Symbol)).void }
    def bad_gateway(message: nil, code: nil)
      message ||= I18n.t('errors.messages.bad_gateway')
      error = generate_json(code:, message:, type: :bad_gateway)
      render json: { error: }, status: :bad_gateway
    end
  end
end
