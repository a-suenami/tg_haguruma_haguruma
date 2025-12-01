# typed: strict
# frozen_string_literal: true

module ContentAuthorizationTags
  class UpsertByRemoteIdService < BaseService
    extend T::Sig

    sig { params(tenant_id: String, remote_id: String, name: String, submitted_at: Time).void }
    def initialize(tenant_id:, remote_id:, name:, submitted_at:)
      @tenant_id = tenant_id
      @remote_id = remote_id
      @name = name
      @submitted_at = submitted_at
      super()
    end

    sig { returns(T.nilable(ContentAuthorizationTag)) }
    def execute
      tag = ContentAuthorizationTag.find_or_initialize_by(
        tenant_id: @tenant_id,
        remote_id: @remote_id,
      )

      # Skip update if the existing record is newer
      return tag if tag.persisted? && tag.updated_at && tag.updated_at >= @submitted_at

      tag.name = @name
      tag.save!
      tag
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("ContentAuthorizationTags::UpsertByRemoteIdService: Failed to upsert tag - #{e.message}")
      nil
    end
  end
end
