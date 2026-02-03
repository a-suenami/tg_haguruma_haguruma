# typed: true
# frozen_string_literal: true

module FeatureFlaggable
  extend ActiveSupport::Concern
  extend T::Sig
  extend T::Helpers

  included do
    T.bind(self, T.class_of(ActionController::Base))
    helper_method :feature_enabled?
  end

  class_methods do
    extend T::Sig

    # Declare required feature flag for entire controller
    # Usage: require_feature :admin_category
    sig { params(flag_name: Symbol).void }
    def require_feature(flag_name)
      before_action -> { require_feature!(flag_name) }
    end
  end

  private

  # Check if feature is enabled for current tenant
  sig { params(flag_name: T.any(Symbol, String)).returns(T::Boolean) }
  def feature_enabled?(flag_name)
    TenantFeatureFlags.enabled?(flag_name, tenant: current_tenant)
  end

  # Raise error or redirect if feature not enabled
  sig { params(flag_name: T.any(Symbol, String)).void }
  def require_feature!(flag_name)
    return if feature_enabled?(flag_name)

    respond_to do |format|
      format.html { redirect_to root_path, alert: 'この機能は現在利用できません' }
      format.json { render json: { error: 'Feature not available' }, status: :forbidden }
      format.turbo_stream { head :forbidden }
    end
  end

  # Helper to get current tenant (override if needed)
  sig { returns(T.nilable(Tenant)) }
  def current_tenant
    Tenant.current
  end
end
