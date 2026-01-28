# typed: true
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

          @draft_version.schedule_publish!(scheduled_time: scheduled_at, job_id: job.job_id)

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

          Time.zone.parse(params[:scheduled_at])
        rescue ArgumentError
          nil
        end

        sig { void }
        def cancel_existing_job
          return if @draft_version&.scheduled_job_id.blank?

          # Solid Queue job cancellation
          SolidQueue::Job.find_by(active_job_id: @draft_version.scheduled_job_id)&.discard
        end
      end
    end
  end
end
