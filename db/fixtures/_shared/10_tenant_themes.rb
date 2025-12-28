# typed: false
# frozen_string_literal: true

# テナントごとのテーマ設定を db/fixtures/_shared/by_tenant/{tenant_id}/theme.yml から読み込む
#
# 前提: 対象テナントが既に存在していること

require 'yaml'

Dir.glob(Rails.root.join('db/fixtures/_shared/by_tenant/*')).each do |tenant_dir|
  tenant_id = File.basename(tenant_dir)
  next unless Tenant.exists?(id: tenant_id)

  theme_path = File.join(tenant_dir, 'theme.yml')
  next unless File.exist?(theme_path)

  config = YAML.load_file(theme_path)
  config.delete('tenant_id')

  theme = TenantTheme.find_or_initialize_by(tenant_id: tenant_id)
  theme.update!(config)

  puts "  ✓ Loaded theme for tenant: #{tenant_id}"
end
