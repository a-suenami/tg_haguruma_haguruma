# typed: strict
# frozen_string_literal: true

module Users
  class FindOrCreateByUidService
    extend T::Sig

    sig { params(provider: OauthProvider, uid: String).void }
    def initialize(provider:, uid:)
      @uid = uid
      @provider = provider
    end

    sig { returns(User) }
    def execute
      user = T.let(nil, T.nilable(User))

      ActiveRecord::Base.transaction do
        user = User.find_by(tenant_id: @provider.tenant_id, uid: @uid)

        if user
          user.update!(oauth_provider: @provider, last_authenticated_at: Time.zone.now)
        else
          user = User.create!(
            tenant_id: @provider.tenant_id,
            oauth_provider: @provider,
            uid: @uid,
            last_authenticated_at: Time.zone.now,
          )
          assign_system_tags(user)
        end
      end

      T.must(user)
    end

    private

    sig { params(user: User).void }
    def assign_system_tags(user)
      public_tag = ContentAuthorizationTag.public_tag
      member_tag = ContentAuthorizationTag.member_tag

      UserTag.create!(user:, content_authorization_tag: public_tag)
      UserTag.create!(user:, content_authorization_tag: member_tag)
    end
  end
end
