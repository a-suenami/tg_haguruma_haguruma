# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - controllers - api - v1 - application controller
# ==============================================================================
module Api
  module V1
    class ApplicationController < ActionController::API
      extend T::Sig

      include Api::ExceptionRescuable

      before_action :set_tenant

      # Returns the current authenticated user based on session token.
      # Returns nil if no valid token is provided (anonymous access).
      sig { returns(T.nilable(User)) }
      def current_user
        @current_user ||= T.let(authenticate_from_token, T.nilable(User))
      end

      private

      sig { returns(T.nilable(Tenant)) }
      def set_tenant
        tenant_id = request.subdomain.split('.').first

        if tenant_id.blank?
          render json: { error: 'Tenant subdomain is required' }, status: :bad_request
          return
        end

        Tenant.current_id = tenant_id
        tenant = Tenant.find_by(id: tenant_id)

        unless tenant
          render json: { error: 'Tenant not found' }, status: :not_found
          return
        end

        tenant
      end

      # Extracts Bearer token from Authorization header.
      # Returns nil if header is missing or malformed.
      sig { returns(T.nilable(String)) }
      def extract_bearer_token
        auth_header = request.headers['Authorization']
        return nil if auth_header.blank?

        match = auth_header.match(/\ABearer\s+(.+)\z/i)
        match&.[](1)
      end

      # Authenticates user from session token.
      # Returns User if valid token found, nil otherwise.
      sig { returns(T.nilable(User)) }
      def authenticate_from_token
        token_value = extract_bearer_token
        return nil if token_value.blank?

        session_token = SessionToken.available.find_by(id: token_value)
        return nil unless session_token

        session_token.user
      end

      # Helper method to require authentication.
      # Use in before_action for protected endpoints.
      sig { void }
      def require_authentication!
        return if current_user.present?

        render json: {
          error: {
            type: 'authentication_error',
            code: 'authentication_required',
            message: 'Authentication required',
          },
        }, status: :unauthorized
      end
    end
  end
end
