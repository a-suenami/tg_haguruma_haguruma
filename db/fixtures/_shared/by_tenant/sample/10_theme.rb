# typed: false
# frozen_string_literal: true

# サンプルテナントのテーマ設定
# theme.yml から読み込んで TenantTheme を作成/更新する

require 'yaml'

theme_path = File.join(__dir__, 'theme.yml')

if File.exist?(theme_path)
  config = YAML.load_file(theme_path)
  config.delete('tenant_id')

  theme = TenantTheme.find_or_initialize_by(tenant_id: TENANT_ID)
  theme.update!(config)

  puts "  Loaded theme for tenant: #{TENANT_ID}"
else
  # theme.yml がない場合はデフォルトで作成
  TenantTheme.find_or_create_by!(tenant_id: TENANT_ID)
  puts "  Created default theme for tenant: #{TENANT_ID}"
end
