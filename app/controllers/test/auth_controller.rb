# typed: true
# frozen_string_literal: true

module Test
  # Authentication bypass controller for E2E tests
  # This controller is ONLY available when ALLOW_AUTH_BYPASS=true
  #
  # SECURITY WARNING: Never enable ALLOW_AUTH_BYPASS in production!
  class AuthController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate!, raise: false
    skip_before_action :set_tenant, raise: false

    before_action :ensure_bypass_allowed

    # GET /test/auth/bypass
    # Params:
    #   - area: 'admin' or 'ruler' (required)
    #   - tenant_id: tenant ID (required for admin area)
    #   - admin_id: specific admin ID (optional, uses first admin for tenant if not provided)
    #   - ruler_id: specific ruler ID (optional, uses first ruler if not provided)
    def bypass
      area = params[:area]

      case area
      when 'admin'
        bypass_admin_auth
      when 'ruler'
        bypass_ruler_auth
      else
        render json: { error: 'Invalid area. Must be "admin" or "ruler"' }, status: :bad_request
      end
    end

    private

    def ensure_bypass_allowed
      return if bypass_allowed?

      render json: { error: 'Auth bypass is not allowed in this environment' }, status: :forbidden
    end

    def bypass_allowed?
      # Only allow in test environment or when explicitly enabled
      Rails.env.test? || ENV['ALLOW_AUTH_BYPASS'] == 'true'
    end

    def bypass_admin_auth
      tenant_id = params[:tenant_id]

      unless tenant_id.present?
        render json: { error: 'tenant_id is required for admin area' }, status: :bad_request
        return
      end

      tenant = Tenant.find_by(id: tenant_id)

      unless tenant
        render json: { error: "Tenant not found: #{tenant_id}" }, status: :not_found
        return
      end

      # Find admin - use specific ID or first admin for tenant
      admin = if params[:admin_id].present?
                Admin.find_by(id: params[:admin_id], tenant_id: tenant_id)
              else
                Admin.find_by(tenant_id: tenant_id)
              end

      unless admin
        render json: { error: "No admin found for tenant: #{tenant_id}" }, status: :not_found
        return
      end

      # Set session
      session[:admin_id] = admin.id
      session[:tenant_id] = tenant_id

      Rails.logger.info "[E2E Test] Auth bypass: admin_id=#{admin.id}, tenant_id=#{tenant_id}"

      redirect_to admin_area_root_path
    end

    def bypass_ruler_auth
      # Find ruler - use specific ID or first ruler
      ruler = if params[:ruler_id].present?
                Ruler.find_by(id: params[:ruler_id])
              else
                Ruler.first
              end

      unless ruler
        render json: { error: 'No ruler found' }, status: :not_found
        return
      end

      # Set session
      session[:ruler_id] = ruler.id

      Rails.logger.info "[E2E Test] Auth bypass: ruler_id=#{ruler.id}"

      redirect_to ruler_area_root_path
    end
  end
end
