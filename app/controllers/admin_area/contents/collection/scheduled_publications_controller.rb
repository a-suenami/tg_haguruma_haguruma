# typed: false
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      class ScheduledPublicationsController < AdminArea::ApplicationController
        extend T::Sig

        before_action :set_content_type
        before_action :set_content_entry
        before_action :set_draft_version

        # POST /admin/contents/types/:content_type_id/entries/:content_entry_id/scheduled_publication
        def create
          scheduled_at = parse_scheduled_time
          unless scheduled_at
            return render json: { error: '日時を入力してください' }, status: :unprocessable_entity
          end

          if scheduled_at <= Time.current
            return render json: { error: '未来の日時を選択してください' }, status: :unprocessable_entity
          end

          unless @draft_version
            return render json: { error: '下書きバージョンがありません' }, status: :unprocessable_entity
          end

          # Cancel existing scheduled job if any
          cancel_existing_job if @draft_version.scheduled_job_id.present?

          # Schedule new job
          job = PublishScheduledContentJob.set(wait_until: scheduled_at).perform_later(
            tenant_id: Tenant.current_id,
            content_type_id: T.must(@content_type).id,
            content_entry_id: T.must(@content_entry).id,
            version_id: @draft_version.id,
          )

          # Use provider_job_id for Sidekiq (jid), fallback to job_id for other adapters
          @draft_version.schedule_publish!(scheduled_time: scheduled_at, job_id: job.provider_job_id || job.job_id)

          render json: {
            success: true,
            scheduled_at: scheduled_at.strftime('%Y-%m-%d %H:%M'),
            message: "#{scheduled_at.strftime('%Y年%m月%d日 %H:%M')}に公開予約しました",
          }
        end

        # DELETE /admin/contents/types/:content_type_id/entries/:content_entry_id/scheduled_publication
        def destroy
          unless @draft_version&.scheduled?
            return render json: { error: '公開予約がありません' }, status: :unprocessable_entity
          end

          cancel_existing_job
          @draft_version.cancel_schedule!

          render json: { success: true, message: '公開予約を解除しました' }
        end

        private

        sig { void }
        def set_content_type
          @content_type = T.let(ContentType.find(params[:content_type_id]), T.nilable(ContentType))
        end

        sig { void }
        def set_content_entry
          @content_entry = T.let(
            T.must(@content_type).content_entries.find(params[:content_entry_id]),
            T.nilable(ContentEntry),
          )
        end

        sig { void }
        def set_draft_version
          @draft_version = T.let(
            ContentEntry::Version.find_by(
              tenant_id: Tenant.current_id,
              content_type_id: T.must(@content_type).id,
              content_entry_id: T.must(@content_entry).id,
              status: ContentEntry::Version::STATUSES[:draft],
            ),
            T.nilable(ContentEntry::Version),
          )
        end

        sig { returns(T.nilable(Time)) }
        def parse_scheduled_time
          return nil if params[:scheduled_at].blank?

          # Parse ISO8601 UTC string from frontend (e.g., "2025-01-29T10:00:00.000Z")
          Time.iso8601(params[:scheduled_at]).in_time_zone
        rescue ArgumentError, TypeError
          # Fallback for legacy format
          Time.zone.parse(params[:scheduled_at])
        rescue StandardError
          nil
        end

        sig { void }
        def cancel_existing_job
          return if @draft_version&.scheduled_job_id.blank?

          # Sidekiq scheduled job cancellation
          scheduled_set = Sidekiq::ScheduledSet.new
          scheduled_set.each do |job|
            if job.jid == @draft_version.scheduled_job_id
              job.delete
              break
            end
          end
        rescue StandardError => e
          Rails.logger.warn "Failed to cancel scheduled job: #{e.message}"
        end
      end
    end
  end
end
