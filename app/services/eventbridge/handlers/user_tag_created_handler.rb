# typed: strict

module Eventbridge::Handlers
  class UserTagCreatedHandler < BaseHandler
    extend T::Sig

    sig { override.params(detail: T::Hash[T.untyped, T.untyped]).void }
    def handle(detail)
      resource = detail['resource']
      return unless resource.is_a?(Hash)

      unique_id = resource['id']&.to_s
      name = resource['name']&.to_s

      if unique_id.blank? || name.blank?
        Rails.logger.warn("UserTagCreatedHandler: missing resource id or name in detail: #{detail}")
        return
      end

      tag = ContentAuthorizationTag.find_or_initialize_by(provider: 'idp', unique_id:)
      tag.name = name
      tag.save!

      Rails.logger.info("UserTagCreatedHandler: synced tag unique_id=#{unique_id} name=#{name}")
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("UserTagCreatedHandler: failed to save tag unique_id=#{unique_id} - #{e.message}")
    end
  end
end
