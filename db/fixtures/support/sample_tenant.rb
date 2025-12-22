# typed: false
# frozen_string_literal: true

module Seeds
  module SampleTenant
    TENANT_ID = 'sample'

    class << self
      def seed
        return if Tenant.exists?(id: TENANT_ID)

        Tenant.create!(
          id: TENANT_ID,
          name: 'サンプルテナント',
          user_page_domain: 'sample.localhost',
        )
        puts "  ✓ Created tenant: #{TENANT_ID}"
      end
    end
  end
end
