# typed: true
# frozen_string_literal: true

module RulerArea
  class FeatureFlagsController < ApplicationController
    extend T::Sig

    before_action :set_tenant

    sig { void }
    def index
      @features = FeatureFlagRegistry.tenant_scoped.map do |key, meta|
        {
          key: key,
          name: meta[:name],
          description: meta[:description],
          enabled: TenantFeatureFlags.enabled?(key, tenant: @tenant),
          globally_enabled: TenantFeatureFlags.globally_enabled?(key)
        }
      end
    end

    sig { void }
    def toggle
      flag_name = params[:id].to_sym

      if TenantFeatureFlags.enabled?(flag_name, tenant: @tenant)
        TenantFeatureFlags.disable(flag_name, @tenant)
        flash[:notice] = "#{FeatureFlagRegistry.get(flag_name)&.dig(:name)} を無効にしました"
      else
        TenantFeatureFlags.enable(flag_name, @tenant)
        flash[:notice] = "#{FeatureFlagRegistry.get(flag_name)&.dig(:name)} を有効にしました"
      end

      redirect_to ruler_area_tenant_feature_flags_path(@tenant)
    end

    private

    sig { void }
    def set_tenant
      @tenant = T.let(Tenant.find(params[:tenant_id]), T.nilable(Tenant))
    end
  end
end
