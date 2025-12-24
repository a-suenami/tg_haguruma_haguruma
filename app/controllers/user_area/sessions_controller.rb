# typed: true
# frozen_string_literal: true

module UserArea
  class SessionsController < ApplicationController
    extend T::Sig

    skip_before_action :authenticate!, only: [:new, :create, :callback, :failure]

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
        redirect_to user_area_login_path, alert: 'OAuth provider is not configured for this tenant'
        return
      end

      # Redirect to OAuth authorization endpoint
      redirect_to oauth_authorization_url(oauth_provider), allow_other_host: true
    end

    # GET /auth/callback - OAuth callback
    sig { void }
    def callback
      auth_info = request.env['omniauth.auth']

      unless auth_info
        redirect_to user_area_login_path, alert: 'Authentication failed'
        return
      end

      uid = auth_info['uid']
      oauth_provider = current_tenant&.oauth_provider

      unless oauth_provider
        redirect_to user_area_login_path, alert: 'OAuth provider not found'
        return
      end

      # Find or create user
      user = User.find_or_initialize_by(
        tenant_id: current_tenant&.id,
        oauth_provider_id: oauth_provider.id,
        uid: uid,
      )

      if user.new_record?
        user.save!
      end

      user.update!(last_authenticated_at: Time.current)

      # Create session
      session[:user_id] = user.id
      session[:tenant_id] = current_tenant&.id

      redirect_to user_area_root_path, notice: 'Logged in successfully'
    end

    # DELETE /logout
    sig { void }
    def destroy
      reset_session
      redirect_to user_area_login_path, notice: 'Logged out successfully'
    end

    # GET /auth/failure
    sig { void }
    def failure
      error_message = params[:message] || 'Unknown error'
      redirect_to user_area_login_path, alert: "Authentication failed: #{error_message}"
    end

    private

    sig { params(oauth_provider: OauthProvider).returns(String) }
    def oauth_authorization_url(oauth_provider)
      endpoint_base = oauth_provider.endpoint_base.chomp('/')
      client_id = oauth_provider.client_id
      redirect_uri = CGI.escape(user_area_callback_url)
      scopes = oauth_provider.scopes.presence || 'openid profile email'

      "#{endpoint_base}/authorize?client_id=#{client_id}&redirect_uri=#{redirect_uri}&response_type=code&scope=#{CGI.escape(scopes)}"
    end

    sig { returns(String) }
    def user_area_callback_url
      url_for(action: :callback, controller: 'user_area/sessions', only_path: false)
    end
  end
end
