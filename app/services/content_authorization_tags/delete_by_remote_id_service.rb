# typed: strict
# frozen_string_literal: true

module ContentAuthorizationTags
  class DeleteByRemoteIdService < BaseService
    extend T::Sig

    sig { params(tenant_id: String, remote_id: String, submitted_at: Time).void }
    def initialize(tenant_id:, remote_id:, submitted_at:)
      @tenant_id = tenant_id
      @remote_id = remote_id
      @submitted_at = submitted_at
      super()
    end

    sig { returns(T::Boolean) }
    def execute
      tag = ContentAuthorizationTag.find_by(
        tenant_id: @tenant_id,
        remote_id: @remote_id,
      )

      return false unless tag

      # Skip delete if the existing record is newer
      return false if tag.updated_at && tag.updated_at >= @submitted_at

      tag.destroy!
      Rails.logger.info("ContentAuthorizationTags::DeleteByRemoteIdService: Deleted tag #{@remote_id}")
      true
    rescue ActiveRecord::RecordNotDestroyed => e
      Rails.logger.error("ContentAuthorizationTags::DeleteByRemoteIdService: Failed to delete tag - #{e.message}")
      false
    end
  end
end
