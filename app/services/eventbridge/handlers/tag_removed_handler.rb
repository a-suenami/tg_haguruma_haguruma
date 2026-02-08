# typed: strict

module Eventbridge::Handlers
  class TagRemovedHandler < BaseHandler
    extend T::Sig

    sig { override.params(detail: T::Hash[T.untyped, T.untyped]).void }
    def handle(detail)
      resource = detail['resource']
      event_data = detail['event_data']
      return unless resource.is_a?(Hash) && event_data.is_a?(Hash)

      user_uid = resource['uid']&.to_s
      tag_id = event_data['tag_id']&.to_s

      if user_uid.blank? || tag_id.blank?
        Rails.logger.warn("TagRemovedHandler: missing uid or tag_id: uid=#{resource['uid']}, tag_id=#{event_data['tag_id']}")
        return
      end

      user = User.find_by(uid: user_uid)
      unless user
        Rails.logger.warn("TagRemovedHandler: user not found uid=#{user_uid}")
        return
      end

      tag = ContentAuthorizationTag.find_by(provider: 'idp', unique_id: tag_id)
      unless tag
        Rails.logger.warn("TagRemovedHandler: tag not found unique_id=#{tag_id}")
        return
      end

      user_tag = UserTag.find_by(user:, content_authorization_tag: tag)
      if user_tag
        user_tag.destroy!
        Rails.logger.info("TagRemovedHandler: removed tag unique_id=#{tag_id} from user uid=#{user_uid}")
      else
        Rails.logger.info("TagRemovedHandler: tag already removed unique_id=#{tag_id} from user uid=#{user_uid}")
      end
    end
  end
end
