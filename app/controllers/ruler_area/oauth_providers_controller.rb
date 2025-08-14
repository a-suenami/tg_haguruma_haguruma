# typed: true
# frozen_string_literal: true

module RulerArea
  class OauthProvidersController < ApplicationController
    before_action :set_tenant

    def index
      # Placeholder for OAuth providers listing
      render html: "<div style='padding: 20px;'><h2>認証プロバイダ一覧</h2><p>この機能は実装中です。</p></div>".html_safe, layout: true
    end

    private

    def set_tenant
      @tenant = Tenant.find(params[:tenant_id])
    end
  end
end
