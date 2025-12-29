# typed: false
# frozen_string_literal: true

# 斧琴菊テナントのテーマ設定（初期データ）
# 既に存在する場合はスキップ
# theme.yml から読み込んで TenantTheme を作成

require 'yaml'

tenant_id = 'yokikotokiku'

if TenantTheme.exists?(tenant_id: tenant_id)
  puts "  Theme: #{tenant_id} (already exists, skipping)"
else
  theme_path = File.join(__dir__, 'theme.yml')

  if File.exist?(theme_path)
    config = YAML.load_file(theme_path)
    config.delete('tenant_id')

    TenantTheme.create!(tenant_id: tenant_id, **config.symbolize_keys)
    puts "  Created theme for tenant: #{tenant_id}"
  else
    TenantTheme.create!(tenant_id: tenant_id)
    puts "  Created default theme for tenant: #{tenant_id}"
  end
end
