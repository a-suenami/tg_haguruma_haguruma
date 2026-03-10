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
      Rails.logger.info("SyncIdpTagsService: starting sync for user=#{@user.id} tags_count=#{@tags.size}")

      @tags.each do |tag_data|
        tag_id = tag_data['id']&.to_s
        if tag_id.blank?
          Rails.logger.warn("SyncIdpTagsService: skipping tag with blank id: #{tag_data.inspect}")
          next
        end

        tag_name = tag_data['name']&.to_s
        if tag_name.blank?
          Rails.logger.warn("SyncIdpTagsService: skipping tag with blank name: #{tag_data.inspect}")
          next
        end

        tag = ContentAuthorizationTag.find_or_initialize_by(provider: 'idp', unique_id: tag_id)
        tag.name = tag_name
        Rails.logger.info("SyncIdpTagsService: saving ContentAuthorizationTag unique_id=#{tag_id} name=#{tag_name} new_record=#{tag.new_record?}")
        tag.save!

        user_tag = UserTag.find_or_create_by!(user: @user, content_authorization_tag: tag)
        Rails.logger.info("SyncIdpTagsService: UserTag id=#{user_tag.id} user=#{@user.id} tag=#{tag.id}")
      rescue ActiveRecord::RecordNotUnique => e
        Rails.logger.warn("SyncIdpTagsService: RecordNotUnique for tag_id=#{tag_id} - #{e.message}")
      rescue StandardError => e
        Rails.logger.error("SyncIdpTagsService: unexpected error for tag_id=#{tag_id} - #{e.class}: #{e.message}")
        raise
      end

      Rails.logger.info("SyncIdpTagsService: completed sync for user=#{@user.id}")
    end
  end
end
