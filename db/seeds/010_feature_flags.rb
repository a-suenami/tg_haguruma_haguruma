# frozen_string_literal: true

# Seed all registered feature flags
puts 'Seeding feature flags...'
FeatureFlagRegistry.seed!
puts "Feature flags seeded: #{FeatureFlagRegistry.all.keys.join(', ')}"
