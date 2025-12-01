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

      private

      sig { returns(T.nilable(Tenant)) }
      def set_tenant
        tenant_id = request.subdomain.split('.').first

        unless tenant_id.present?
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
    end
  end
end
