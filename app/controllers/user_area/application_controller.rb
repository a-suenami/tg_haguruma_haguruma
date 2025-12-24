# typed: true
# frozen_string_literal: true

module UserArea
  class ApplicationController < ::ApplicationController
    extend T::Sig

    layout 'user_area/application'

    before_action :set_tenant
    before_action :authenticate!

    helper_method :current_user, :user_signed_in?, :current_tenant

    sig { void }
    def authenticate!
      redirect_to user_area_login_path unless user_signed_in?
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
  end
end
