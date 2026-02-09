# typed: true
# frozen_string_literal: true

module UserArea
  class SessionsController < ApplicationController
    extend T::Sig

    # GET /login
    sig { void }
    def new
      redirect_to user_area_root_path if user_signed_in?
    end

    # POST /login - Redirect to OAuth provider
    sig { void }
    def create
      oauth_provider = current_tenant&.oauth_provider

      unless oauth_provider
        redirect_to user_area_login_path, alert: t('user_area.sessions.oauth_provider_not_configured')
        return
      end

      # Generate and store state for CSRF protection
      state = SecureRandom.urlsafe_base64(32)
      session[:oauth_state] = state

      # Redirect to OAuth authorization endpoint
      signup = params[:signup].present?
      redirect_to oauth_authorization_url(oauth_provider, state:, signup:), allow_other_host: true
    end

    # GET /auth/callback - OAuth callback
    sig { void }
    def callback
      # Check for OAuth error response (user cancelled, access denied, etc.)
      if params[:error].present?
        Rails.logger.info("OAuth callback error: #{params[:error]} - #{params[:error_description]}")
        session.delete(:oauth_state)
        redirect_to user_area_auth_error_path
        return
      end

      # Verify state parameter for CSRF protection
      unless valid_oauth_state?
        redirect_to user_area_login_path, alert: t('user_area.sessions.invalid_state_parameter')
        return
      end

      code = params[:code]
      if code.blank?
        session.delete(:oauth_state)
        redirect_to user_area_auth_error_path
        return
      end

      oauth_provider = current_tenant&.oauth_provider
      unless oauth_provider
        redirect_to user_area_login_path, alert: t('user_area.sessions.oauth_provider_not_found')
        return
      end

      begin
        # Exchange authorization code for tokens
        token_result = Auth::IdPlatform::ExchangeCodeService.new(oauth_provider:).execute(
          code:,
          redirect_uri: user_area_callback_url,
        )

        # Verify ID token
        payload = Auth::IdPlatform::VerifyIdTokenService.new(oauth_provider:).execute(
          id_token_jwt: token_result.id_token,
        )

        uid = payload['sub']
        if uid.blank?
          redirect_to user_area_login_path, alert: t('user_area.sessions.invalid_id_token_missing_subject')
          return
        end

        # Find or create user
        user = User.find_or_initialize_by(
          tenant_id: current_tenant&.id,
          oauth_provider_id: oauth_provider.id,
          uid:,
        )

        if user.new_record?
          user.save!
        end

        user.update!(last_authenticated_at: Time.current)

        # Create session
        session[:user_id] = user.id
        session[:tenant_id] = current_tenant&.id
        session.delete(:oauth_state)

        redirect_to user_area_root_path, notice: t('user_area.sessions.logged_in_successfully')
      rescue Auth::IdPlatform::ExchangeCodeService::Error => e
        Rails.logger.error("OAuth code exchange failed: #{e.message}")
        redirect_to user_area_login_path, alert: t('user_area.sessions.exchange_code_failed')
      rescue JWT::DecodeError => e
        Rails.logger.error("ID token verification failed: #{e.message}")
        redirect_to user_area_login_path, alert: t('user_area.sessions.invalid_id_token')
      end
    end

    # DELETE /logout
    sig { void }
    def destroy
      oauth_provider = current_tenant&.oauth_provider

      # Clear local session first
      reset_session

      # Redirect to IDP logout to clear IDP session
      if oauth_provider.present?
        redirect_to idp_logout_url(oauth_provider), allow_other_host: true
        return
      end

      # Fallback: no OAuth provider configured
      redirect_to user_area_root_path, notice: t('user_area.sessions.logged_out_successfully')
    end

    # GET /auth/failure
    sig { void }
    def failure
      error_message = params[:message] || 'Unknown error'
      redirect_to user_area_login_path, alert: t('user_area.sessions.authentication_failed', error: error_message)
    end

    # GET /dev/skip_auth (development only)
    sig { void }
    def dev_skip_auth
      oauth_provider = current_tenant&.oauth_provider
      unless oauth_provider
        redirect_to user_area_login_path, alert: t('user_area.sessions.oauth_provider_not_configured_short')
        return
      end

      # Find or create a dev user
      user = User.find_or_create_by!(
        tenant_id: current_tenant&.id,
        oauth_provider_id: oauth_provider.id,
        uid: 'dev-user',
      )

      session[:user_id] = user.id
      session[:tenant_id] = current_tenant&.id

      redirect_to user_area_root_path, notice: t('user_area.sessions.logged_in_as_dev_user')
    end

    private

    sig { returns(T::Boolean) }
    def valid_oauth_state?
      state_param = params[:state]
      stored_state = session[:oauth_state]
      state_param.present? && stored_state.present? && ActiveSupport::SecurityUtils.secure_compare(state_param.to_s, stored_state.to_s)
    end

    sig { params(oauth_provider: OauthProvider, state: String, signup: T::Boolean).returns(String) }
    def oauth_authorization_url(oauth_provider, state:, signup: false)
      endpoint_base = oauth_provider.endpoint_base.chomp('/')
      client_id = oauth_provider.client_id
      redirect_uri = CGI.escape(user_area_callback_url)
      scopes = oauth_provider.scopes.presence || 'openid profile email'

      url = "#{endpoint_base}/oauth/authorize?client_id=#{client_id}&redirect_uri=#{redirect_uri}&response_type=code&scope=#{CGI.escape(scopes)}&state=#{state}"
      url += '&on_no_session=sign_up' if signup
      url
    end

    sig { returns(String) }
    def user_area_callback_url
      url_for(action: :callback, controller: 'user_area/sessions', only_path: false)
    end

    sig { params(oauth_provider: OauthProvider).returns(String) }
    def idp_logout_url(oauth_provider)
      endpoint_base = oauth_provider.endpoint_base.chomp('/')
      client_id = oauth_provider.client_id
      return_to = CGI.escape(user_area_root_url)

      "#{endpoint_base}/logout?client_id=#{client_id}&returnTo=#{return_to}"
    end

    sig { returns(String) }
    def user_area_root_url
      url_for(action: :index, controller: 'user_area/alpha/root', only_path: false)
    end
  end
end
