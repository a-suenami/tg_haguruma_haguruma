# typed: strict

module Eventbridge::Handlers
  class TagAddedHandler < BaseHandler
    extend T::Sig

    sig { override.params(detail: T::Hash[T.untyped, T.untyped]).void }
    def handle(detail)
      resource = detail['resource']
      event_data = detail['event_data']
      return unless resource.is_a?(Hash) && event_data.is_a?(Hash)

      user_uid = resource['uid']&.to_s
      tag_id = event_data['tag_id']&.to_s

      if user_uid.blank? || tag_id.blank?
        Rails.logger.warn("TagAddedHandler: missing uid or tag_id: uid=#{resource['uid']}, tag_id=#{event_data['tag_id']}")
        return
      end

      user = User.find_by(uid: user_uid)
      unless user
        Rails.logger.warn("TagAddedHandler: user not found uid=#{user_uid}")
        return
      end

      tag = ContentAuthorizationTag.find_by(provider: 'idp', unique_id: tag_id)
      unless tag
        Rails.logger.warn("TagAddedHandler: tag not found unique_id=#{tag_id}")
        return
      end

      UserTag.find_or_create_by!(user:, content_authorization_tag: tag)

      Rails.logger.info("TagAddedHandler: assigned tag unique_id=#{tag_id} to user uid=#{user_uid}")
    rescue ActiveRecord::RecordNotUnique
      # Already exists — idempotent
      Rails.logger.info("TagAddedHandler: tag already assigned unique_id=#{tag_id} to user uid=#{user_uid}")
    end
  end
end
