# typed: true
# frozen_string_literal: true

module AdminArea
  class Auth0Controller < ApplicationController
    # Skip authentication for login, callback, and failure actions
    skip_before_action :authenticate!, only: [:login, :callback, :failure]
    skip_before_action :verify_authenticity_token, only: [:callback]
    skip_before_action :set_tenant, only: [:login, :callback, :failure]

    def login
      redirect_to admin_area_root_path, notice: t('admin_area.auth0.already_logged_in') if admin_signed_in?
    end

    def callback
      auth_info = request.env['omniauth.auth']

      redirect_to admin_area_login_path, alert: t('admin_area.auth0.auth_info_not_found') unless auth_info

      uid = auth_info['uid']

      # Detect tenant from subdomain
      tenant_id = detect_tenant_id

      unless tenant_id
        reset_session
        flash[:alert] = t('admin_area.auth0.tenant_not_found')
        redirect_to auth0_logout_url, allow_other_host: true
        return
      end

      # Verify tenant exists
      tenant = Tenant.find_by(id: tenant_id)

      unless tenant
        reset_session
        flash[:alert] = t('admin_area.auth0.tenant_not_found')
        redirect_to auth0_logout_url, allow_other_host: true
        return
      end

      # Find Admin by Auth0 UID for this tenant
      begin
        auth0_account = Auth0Account.find_by!(uid:)
        admin_link = auth0_account.admin_auth0_accounts.find_by(tenant_id:)

        unless admin_link
          reset_session
          flash[:alert] = t('admin_area.auth0.no_admin_access')
          redirect_to auth0_logout_url, allow_other_host: true
          return
        end

        admin = admin_link.admin

        unless admin
          reset_session
          flash[:alert] = t('admin_area.auth0.admin_not_found')
          redirect_to auth0_logout_url, allow_other_host: true
          return
        end

        # Create session
        session[:admin_id] = admin.id
        session[:tenant_id] = tenant_id

        redirect_to admin_area_root_path, notice: t('admin_area.auth0.logged_in')
      rescue ActiveRecord::RecordNotFound
        reset_session
        flash[:alert] = t('admin_area.auth0.account_not_registered')
        redirect_to auth0_logout_url, allow_other_host: true
      end
    end

    def logout
      current_admin&.name
      reset_session
      redirect_to auth0_logout_url, allow_other_host: true
    end

    def failure
      error_message = params[:message] || 'Unknown error'
      params[:strategy] || 'auth0_admin'

      redirect_to admin_area_login_path, alert: t('admin_area.auth0.authentication_failed', error: error_message)
    end

    private

    def auth0_logout_url
      domain = Settings.auth0.admin.domain
      client_id = Settings.auth0.admin.client_id
      return_to = CGI.escape(admin_area_login_url)

      # For Auth0 Database (email/password), it has no effect
      "https://#{domain}/v2/logout?client_id=#{client_id}&returnTo=#{return_to}"
    end

    def detect_tenant_id
      # Extract tenant ID from subdomain
      # Example: sample.idp.localhost:3000 → "sample"
      #          tenant-a.idp.localhost:3000 → "tenant-a"
      subdomain = request.subdomain

      # Split by '.' and take first part
      # "sample.idp" → "sample"
      # "sample" → "sample"
      parts = subdomain.split('.')
      parts.first unless parts.first.in?(['', 'www', 'app'])
    end

    def current_admin
      @current_admin ||= Admin.find_by(id: session[:admin_id]) if session[:admin_id]
    end

    def admin_signed_in?
      current_admin.present? && session[:tenant_id].present?
    end
  end
end
