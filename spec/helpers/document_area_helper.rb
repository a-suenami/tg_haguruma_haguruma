# typed: true

# ==============================================================================
# spec/helpers/document_area_helper.rb
# ==============================================================================
module DocumentAreaHelper
  extend ActiveSupport::Concern

  T.bind(self, T.untyped)

  included do
    let(:current_tenant) { create(:tenant, id: :kenshiyonezu, name: 'Yonezu Kenshi', user_page_domain: 'kenshiyonezu.triple.test') }

    before do
      Tenant.current_id = current_tenant.id
      host! "#{current_tenant.id}.t-riple.com"
    end
  end
end
