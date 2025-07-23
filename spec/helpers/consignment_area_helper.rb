# typed: true

# ==============================================================================
# spec/helpers/consignment_area_helper.rb
# ==============================================================================
module ConsignmentAreaHelper
  extend ActiveSupport::Concern

  T.bind(self, T.untyped)

  included do
    let(:current_tenant) { create(:tenant, id: :kenshiyonezu, name: 'Yonezu Kenshi', user_page_domain: 'kenshiyonezu.triple.test') }
    let(:current_user) { nil }
    let(:consignment_access_key) { nil }

    before do
      Tenant.current_id = current_tenant.id
      host! "#{current_tenant.id}.t-riple.com"

      headers['Authorization'] = "Bearer #{consignment_access_key&.secret_key}"

      if current_user
        headers['X-Triple-Consignment-User-Uid'] = current_user.uid
      end
    end
  end
end
