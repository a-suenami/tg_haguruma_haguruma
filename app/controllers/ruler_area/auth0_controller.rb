# typed: true
# frozen_string_literal: true

module RulerArea
  class Auth0Controller < ApplicationController
    # Skip authentication for login, callback, and failure actions
    skip_before_action :authenticate!, only: [:login, :callback, :failure]
    skip_before_action :verify_authenticity_token, only: [:callback]

    def login
      redirect_to ruler_area_root_path, notice: t('ruler_area.auth0.already_logged_in') if ruler_signed_in?
    end

    def callback
      auth_info = request.env['omniauth.auth']

      redirect_to ruler_area_login_path, alert: t('ruler_area.auth0.auth_info_not_found') unless auth_info

      uid = auth_info['uid']
      email = auth_info.dig('info', 'email')

      Rails.logger.info "Auth0 callback: uid=#{uid}, email=#{email}"

      # Find Ruler by Auth0 UID (simplified with has_one relationship)
      begin
        ruler = Auth0Account.find_by!(uid:).ruler

        unless ruler
          Rails.logger.warn "Ruler not found for auth0_account: uid=#{uid}"
          reset_session
          flash[:alert] = t('ruler_area.auth0.no_ruler_access')
          redirect_to auth0_logout_url, allow_other_host: true
          return
        end

        # Create session
        session[:ruler_id] = ruler.id

        redirect_to ruler_area_root_path, notice: t('ruler_area.auth0.logged_in')
      rescue ActiveRecord::RecordNotFound
        Rails.logger.warn "Auth0 account not found: uid=#{uid}, email=#{email}"
        reset_session
        flash[:alert] = t('ruler_area.auth0.account_not_registered')
        redirect_to auth0_logout_url, allow_other_host: true
      end
    end

    def logout
      current_ruler&.email
      reset_session
      redirect_to auth0_logout_url, allow_other_host: true
    end

    def failure
      error_message = params[:message] || 'Unknown error'
      params[:strategy] || 'auth0'

      redirect_to ruler_area_login_path, alert: t('ruler_area.auth0.authentication_failed', error: error_message)
    end

    private

    def auth0_logout_url
      domain = Settings.auth0.ruler.domain
      client_id = Settings.auth0.ruler.client_id
      return_to = CGI.escape(ruler_area_login_url)

      # For Auth0 Database (email/password), it has no effect
      "https://#{domain}/v2/logout?client_id=#{client_id}&returnTo=#{return_to}"
    end

    def current_ruler
      @current_ruler ||= Ruler.find_by(id: session[:ruler_id]) if session[:ruler_id]
    end

    def ruler_signed_in?
      current_ruler.present?
    end
  end
end
