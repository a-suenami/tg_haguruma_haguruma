# ==============================================================================
# spec - helpers - preview api helper
# ==============================================================================
module PreviewAPIHelper
  extend ActiveSupport::Concern

  included do
    let(:current_tenant) { create(:tenant, id: :kenshiyonezu, name: 'Yonezu Kenshi', user_page_domain: 'kenshiyonezu.triple.test') }
    let!(:user_oauth_provider) { create(:oauth_provider, tenant_id: current_tenant.id, kind: OauthProvider::KindEnum::User.serialize) }
    let(:current_user) { nil }
    let(:phone_number) { '+16505553434' }
    let(:email) { 'mail@example.com' }

    before do
      Tenant.current_id = current_tenant.id
      host! "#{current_tenant.id}.t-riple.com"
      headers['Content-Type'] = 'application/json' if http_method.in?(%w[post patch put])

      if current_user
        allow_any_instance_of(API::V1::Preview::ApplicationController).to receive(:current_user).and_return(current_user)
      end
    end
  end
end
