# typed: true
# frozen_string_literal: true

module RulerArea
  class AdminsController < ApplicationController
    before_action :set_tenant

    def index
      # Placeholder for admins listing
      render html: "<div style='padding: 20px;'><h2>管理者一覧</h2><p>この機能は実装中です。</p></div>".html_safe, layout: true
    end

    private

    def set_tenant
      @tenant = Tenant.find(params[:tenant_id])
    end
  end
end
