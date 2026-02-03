# typed: true
# frozen_string_literal: true

module RulerArea
  class GlobalFeatureFlagsController < ApplicationController
    extend T::Sig

    sig { void }
    def index
      @features = FeatureFlagRegistry.all.map do |key, meta|
        enabled_tenants = TenantFeatureFlags.enabled_tenants(key)
        {
          key: key,
          name: meta[:name],
          description: meta[:description],
          scope: meta[:scope],
          globally_enabled: TenantFeatureFlags.globally_enabled?(key),
          enabled_tenant_count: enabled_tenants.size,
          enabled_tenants: enabled_tenants.first(5) # Show first 5 for preview
        }
      end
    end

    sig { void }
    def toggle
      flag_name = params[:id].to_sym
      flag_meta = FeatureFlagRegistry.get(flag_name)

      if TenantFeatureFlags.globally_enabled?(flag_name)
        TenantFeatureFlags.disable_globally(flag_name)
        flash[:notice] = "#{flag_meta&.dig(:name)} をグローバルで無効にしました"
      else
        TenantFeatureFlags.enable_globally(flag_name)
        flash[:notice] = "#{flag_meta&.dig(:name)} をグローバルで有効にしました（全テナント）"
      end

      redirect_to ruler_area_global_feature_flags_path
    end
  end
end
