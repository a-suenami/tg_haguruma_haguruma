# typed: strict
# frozen_string_literal: true

module Users
  class SyncIdpTagsService
    extend T::Sig

    sig { params(user: User, tags: T::Array[T::Hash[String, T.untyped]]).void }
    def initialize(user:, tags:)
      @user = user
      @tags = tags
    end

    sig { void }
    def execute
      @tags.each do |tag_data|
        tag_id = tag_data['id']&.to_s
        next if tag_id.blank?

        tag_name = tag_data['name']&.to_s
        next if tag_name.blank?

        tag = ContentAuthorizationTag.find_or_initialize_by(provider: 'idp', unique_id: tag_id)
        tag.name = tag_name
        tag.save!

        UserTag.find_or_create_by!(user: @user, content_authorization_tag: tag)
      rescue ActiveRecord::RecordNotUnique
        # Already exists - idempotent
      end
    end
  end
end
