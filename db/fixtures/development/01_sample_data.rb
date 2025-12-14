# typed: false
# frozen_string_literal: true

# Development environment seed data
# Creates sample tenant with article content type and 10 sample entries

require_relative '../../../lib/seeds/sample_data_seeder'

puts '== Seeding sample data for development =='
Seeds::SampleDataSeeder.seed_all
puts '== Done =='
