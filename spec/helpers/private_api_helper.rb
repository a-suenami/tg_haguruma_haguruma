# ==============================================================================
# spec - helpers - private api helper
# ==============================================================================
module PrivateAPIHelper
  extend ActiveSupport::Concern
  include APIHelper

  included do
    let(:current_tenant) { create(:tenant, id: :kenshiyonezu, name: 'Yonezu Kenshi', user_page_domain: 'kenshiyonezu.triple.test') }
    let!(:user_oauth_provider) { create(:oauth_provider, tenant_id: current_tenant.id, kind: OauthProvider::KindEnum::User.serialize) }
    let(:current_user) { nil }
    let(:current_user_token) { 'session_token' }
    let(:phone_number) { '+16505553434' }
    let(:email) { 'mail@example.com' }

    before do
      Tenant.current_id = current_tenant.id
      host! "#{current_tenant.id}.t-riple.com"
      headers['Content-Type'] = 'application/json' if http_method.in?(%w[post patch put])

      if current_user.persisted?
        SessionToken.create!(id: current_user_token, user: current_user, expires_at: 1.week.from_now)
        allow_any_instance_of(API::V1::Private::ApplicationController).to receive(:_token).and_return(current_user_token)
      elsif current_user.id == '00000000-0000-0000-0000-000000000000'
        allow_any_instance_of(API::V1::Private::ApplicationController).to receive(:_token).and_return('anonymous')
      end
    end
  end
end
