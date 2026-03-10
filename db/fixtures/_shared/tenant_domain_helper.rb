# typed: false
# frozen_string_literal: true

# テナント設定のヘルパー
# 環境ごとに異なるテナントIDとドメインパターンを返す
#
# Usage:
#   TenantDomainHelper.tenant_id_for('yokikotokiku')
#   #=> 'demo-yokikotokiku' (in staging)
#   #=> 'yokikotokiku' (in production)
#
#   TenantDomainHelper.user_page_domain_for('sample')
#   #=> 'sample.api.haguruma.localhost' (in development)

module TenantDomainHelper
  module_function

  # 環境ごとのドメインサフィックス
  # TODO: api. を user. や何もなし(つまり、{tenant_id}.app.haguruma.io) にしたい。本番も同様。
  DOMAIN_SUFFIXES = {
    'development' => 'api.haguruma.localhost',
    'test' => 'api.haguruma.localhost',
    'staging' => 'api.app-staging.haguruma.io',
    'production' => 'api.app.haguruma.io',
  }.freeze

  # 環境ごとにプレフィックスを付ける
  # - development: dev-
  # - staging: demo-
  # - production: なし
  # ※ sample は特別扱いでプレフィックスを付けない
  def tenant_id_for(base_id)
    return base_id if base_id == 'sample'

    case Rails.env
    when 'development'
      "dev-#{base_id}"
    when 'staging'
      "demo-#{base_id}"
    else
      base_id
    end
  end

  def user_page_domain_for(tenant_id)
    suffix = DOMAIN_SUFFIXES[Rails.env] || DOMAIN_SUFFIXES['production']
    "#{tenant_id}.#{suffix}"
  end
end
