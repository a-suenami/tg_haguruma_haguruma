# typed: false
# frozen_string_literal: true

# テナントドメイン設定のヘルパー
# 環境ごとに異なるドメインパターンを返す
#
# Usage:
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

  def user_page_domain_for(tenant_id)
    suffix = DOMAIN_SUFFIXES[Rails.env] || DOMAIN_SUFFIXES['production']
    "#{tenant_id}.#{suffix}"
  end
end
