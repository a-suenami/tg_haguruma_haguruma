# ==============================================================================
# spec - helpers - public api helper
# ==============================================================================
module PublicAPIHelper
  extend ActiveSupport::Concern
  include APIHelper

  included do
    let(:current_tenant) { create(:tenant, id: :kenshiyonezu, name: 'Yonezu Kenshi', user_page_domain: 'kenshiyonezu.triple.test') }

    before do
      Tenant.current_id = current_tenant.id
      host! "#{current_tenant.id}.t-riple.com"
    end
  end
end
