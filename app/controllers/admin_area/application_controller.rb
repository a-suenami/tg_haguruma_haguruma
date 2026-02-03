# typed: true
# frozen_string_literal: true

class AdminArea::ApplicationController < ApplicationController
  extend T::Sig
  include FeatureFlaggable

  layout 'admin_area/application'

  before_action :authenticate!
  before_action :set_tenant

  helper AdminArea::PreviewHelper
  helper_method :current_admin, :signed_in?

  sig { void }
  def authenticate!
    redirect_to admin_area_login_path unless signed_in?
  end

  sig { returns(T.nilable(Admin)) }
  def current_admin
    @current_admin ||= T.let(
      Admin.includes(:auth0_account).find_by(id: session[:admin_id]),
      T.nilable(Admin),
    )
  end

  sig { returns(T::Boolean) }
  def signed_in?
    current_admin.present?
  end

  private

  sig { returns(T.nilable(Tenant)) }
  def set_tenant
    Tenant.current_id = request.subdomain.split('.').first
    Tenant.current
  end

  sig { returns(T::Boolean) }
  def mobile_request?
    request.user_agent&.match?(/Mobile|Android|iPhone|iPad/i) || false
  end

  sig { void }
  def render_not_found
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end
end
