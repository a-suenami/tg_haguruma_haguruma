# typed: false
# frozen_string_literal: true

class PublishScheduledContentJob < ApplicationJob
  queue_as :default

  def perform(tenant_id:, content_type_id:, content_entry_id:, version_id:)
    Tenant.current_id = tenant_id

    version = ContentEntry::Version.find_by(id: version_id)
    return unless version&.scheduled? # Already published or schedule cancelled

    content_type = ContentType.find(content_type_id)
    content_entry = content_type.content_entries.find(content_entry_id)

    result = AdminArea::Contents::PublishEntryService.new(
      content_type:,
      content_entry:,
    ).call

    if result.success
      # Clear scheduled fields after successful publish
      version.reload.update!(scheduled_publish_at: nil, scheduled_job_id: nil)
      Rails.logger.info "Scheduled publish completed for entry #{content_entry_id}"
    else
      Rails.logger.error "Scheduled publish failed for entry #{content_entry_id}: #{result.errors.join(', ')}"
      # TODO: Notify admin of failure
    end
  ensure
    Tenant.current_id = nil
  end
end
