# typed: false
# frozen_string_literal: true

module FeatureFlaggable
  extend ActiveSupport::Concern

  included do
    helper_method :feature_enabled?
  end

  class_methods do
    # Declare required feature flag for entire controller
    # Usage: require_feature :admin_category
    def require_feature(flag_name, **)
      before_action(**) do
        require_feature!(flag_name)
      end
    end
  end

  private

  def feature_enabled?(flag_name)
    TenantFeatureFlags.enabled?(flag_name)
  end

  def require_feature!(flag_name)
    return if feature_enabled?(flag_name)

    respond_to do |format|
      format.html do
        flash[:alert] = I18n.t('feature_flags.errors.not_available')
        redirect_back fallback_location: '/'
      end
      format.json do
        render json: { error: 'Feature not available' }, status: :forbidden
      end
    end
  end
end
