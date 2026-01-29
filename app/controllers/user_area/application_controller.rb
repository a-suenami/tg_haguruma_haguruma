# typed: true
# frozen_string_literal: true

module UserArea
  class ApplicationController < ::ApplicationController
    extend T::Sig

    layout 'user_area/application'

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    before_action :set_tenant
    before_action :authenticate_with_basic_auth

    helper UserArea::SiteSettingsHelper
    helper UserArea::CustomVariablesHelper
    helper_method :current_user, :user_signed_in?, :current_tenant

    sig { void }
    def authenticate!
      return if Rails.env.development? && skip_auth_in_development?

      redirect_to user_area_login_path unless user_signed_in?
    end

    sig { returns(T::Boolean) }
    def skip_auth_in_development?
      params[:skip_auth] == 'true' || session[:skip_auth] == true
    end

    sig { returns(T.nilable(User)) }
    def current_user
      return @current_user if defined?(@current_user)

      @current_user = T.let(nil, T.nilable(User))
      return @current_user unless session[:user_id] && session[:tenant_id]

      @current_user = User.find_by(id: session[:user_id], tenant_id: session[:tenant_id])
    end

    sig { returns(T::Boolean) }
    def user_signed_in?
      current_user.present? && current_tenant.present?
    end

    sig { returns(T.nilable(Tenant)) }
    def current_tenant
      Tenant.current
    end

    private

    sig { returns(T.nilable(Tenant)) }
    def set_tenant
      tenant = Tenant.find_by(user_page_domain: request.host)
      unless tenant
        render plain: 'Tenant not found', status: :not_found
        return nil
      end

      Tenant.current_id = tenant.id
      tenant
    end

    sig { void }
    def authenticate_with_basic_auth
      basic_auth = current_tenant&.basic_auth
      return unless basic_auth&.enabled?

      authenticate_or_request_with_http_basic do |username, password|
        basic_auth.authenticate_credentials(username, password)
      end
    end

    sig { void }
    def render_not_found
      render 'user_area/errors/404', layout: false, status: :not_found
    end
  end
end
