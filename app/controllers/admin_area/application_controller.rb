# typed: true
# frozen_string_literal: true

class AdminArea::ApplicationController < ApplicationController
  extend T::Sig

  layout 'admin_area/application'

  before_action :authenticate!
  before_action :set_tenant

  helper_method :current_admin, :signed_in?

  sig { void }
  def authenticate!
    redirect_to admin_area_login_path unless signed_in?
  end

  sig { returns(T.nilable(Admin)) }
  def current_admin
    @current_admin ||= T.let(Admin.find_by(id: session[:admin_id]), T.nilable(Admin))
  end

  sig { returns(T::Boolean) }
  def signed_in?
    current_admin.present? && session[:tenant_id].present?
  end

  private

  sig { returns(T.nilable(Tenant)) }
  def set_tenant
    tenant_id = session[:tenant_id]

    unless tenant_id
      Rails.logger.warn 'Tenant ID not found in session'
      reset_session
      redirect_to admin_area_login_path, alert: t('admin_area.auth0.session_expired')
      return
    end

    # Set current tenant in RequestStore for tenant-scoped queries
    RequestStore.store[:current_tenant] = tenant_id.to_sym
    tenant = Tenant.find_by(id: tenant_id)

    unless tenant
      Rails.logger.warn "Tenant not found: tenant_id=#{tenant_id}"
      reset_session
      redirect_to admin_area_login_path, alert: t('admin_area.auth0.tenant_not_found')
      return
    end

    Tenant.current
  end

  sig { returns(T::Boolean) }
  def mobile_request?
    request.user_agent&.match?(/Mobile|Android|iPhone|iPad/i) || false
  end
end
