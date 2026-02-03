# typed: true
# frozen_string_literal: true

class TenantFeatureFlags
  extend T::Sig

  class << self
    extend T::Sig

    sig { params(flag_name: T.any(Symbol, String), tenant: T.nilable(Tenant)).returns(T::Boolean) }
    def enabled?(flag_name, tenant: Tenant.current)
      return false unless tenant
      return false unless FeatureFlagRegistry.feature_exists?(flag_name)

      Flipper.enabled?(flag_name, tenant)
    end

    sig { params(flag_name: T.any(Symbol, String), tenant: Tenant).returns(T::Boolean) }
    def enable(flag_name, tenant)
      return false unless FeatureFlagRegistry.feature_exists?(flag_name)

      Flipper.enable(flag_name, tenant)
      true
    end

    sig { params(flag_name: T.any(Symbol, String), tenant: Tenant).returns(T::Boolean) }
    def disable(flag_name, tenant)
      return false unless FeatureFlagRegistry.feature_exists?(flag_name)

      Flipper.disable(flag_name, tenant)
      true
    end

    sig { params(flag_name: T.any(Symbol, String)).returns(T::Boolean) }
    def enable_globally(flag_name)
      return false unless FeatureFlagRegistry.feature_exists?(flag_name)

      Flipper.enable(flag_name)
      true
    end

    sig { params(flag_name: T.any(Symbol, String)).returns(T::Boolean) }
    def disable_globally(flag_name)
      return false unless FeatureFlagRegistry.feature_exists?(flag_name)

      Flipper.disable(flag_name)
      true
    end

    sig { params(flag_name: T.any(Symbol, String)).returns(T::Boolean) }
    def globally_enabled?(flag_name)
      Flipper[flag_name].boolean_value
    end

    sig { params(flag_name: T.any(Symbol, String)).returns(T::Array[String]) }
    def enabled_tenants(flag_name)
      feature = Flipper[flag_name]
      actor_ids = feature.actors_value.to_a
      actor_ids.map { |id| id.sub('Tenant:', '') }
    end
  end
end
