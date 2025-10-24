# frozen_string_literal: true

# ==============================================================================
# Haguruma Seeds
# ==============================================================================
# This file loads all seed files from db/seeds/ directory in alphabetical order
#
# Usage:
#   rails db:seed                    # Load all seeds
#   SEED_FILE=001_rulers rails db:seed  # Load specific seed file
#
# Structure:
#   db/seeds/
#     001_rulers.rb      - Rulers & Auth0 accounts
#     002_admins.rb      - Admins & Auth0 accounts
#     003_tenants.rb     - Tenants
#     999_sample_data.rb - Development sample data (future)

puts "🌱 Loading Haguruma seeds...\n"

# Check if specific seed file is requested
if ENV['SEED_FILE']
  seed_file = Rails.root.join('db/seeds', "#{ENV['SEED_FILE']}.rb")
  if File.exist?(seed_file)
    puts "📂 Loading #{ENV.fetch('SEED_FILE', nil)}.rb..."
    load seed_file
  else
    puts "❌ Seed file not found: #{ENV.fetch('SEED_FILE', nil)}.rb"
    exit 1
  end
else
  # Load all seed files in order
  seed_files = Dir[Rails.root.join('db/seeds/*.rb')]

  if seed_files.empty?
    puts '⚠️  No seed files found in db/seeds/'
    exit 0
  end

  seed_files.each do |file|
    puts "\n📂 Loading #{File.basename(file)}..."
    load file
  end
end

puts "\n#{'=' * 80}"
puts '🎉 Seeding completed!'
puts '=' * 80

puts "\n📊 Database Summary:"
puts "   - Auth0Accounts: #{Auth0Account.count}"
puts "   - Rulers: #{Ruler.count}"
puts "   - Ruler::Auth0Account: #{Ruler::Auth0Account.count}"
puts "   - Admins: #{Admin.count}"
puts "   - Admin::Auth0Account: #{Admin::Auth0Account.count}"
puts "   - Tenants: #{Tenant.count}"

puts "\n🔗 Login URLs:"
puts '   Ruler: http://idp.localhost:3000/ruler/login'
puts '   Admin: http://sample.idp.localhost:3000/admin/login'

puts "\n💡 Tips:"
puts '   - Load all seeds: rails db:seed'
puts '   - Load specific seed: SEED_FILE=001_rulers rails db:seed'
puts '   - Reset & seed: rails db:reset'
puts ''
