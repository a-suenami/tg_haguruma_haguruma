# frozen_string_literal: true

# Seed all registered feature flags
Rails.logger.info 'Seeding feature flags...'
FeatureFlagRegistry.seed!
Rails.logger.info "Feature flags seeded: #{FeatureFlagRegistry.all.keys.join(', ')}"
