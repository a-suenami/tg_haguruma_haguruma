# typed: false
# frozen_string_literal: true

module RulerArea
  module TenantSettable
    extend ActiveSupport::Concern

    private

    def set_tenant
      @tenant = Tenant.find(params[:tenant_id])
      Tenant.current_id = @tenant.id
    end
  end
end
