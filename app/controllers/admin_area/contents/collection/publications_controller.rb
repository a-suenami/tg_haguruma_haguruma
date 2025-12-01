# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      class PublicationsController < AdminArea::ApplicationController
        extend T::Sig

        before_action :set_content_type
        before_action :set_content_entry

        def create
          result = AdminArea::Contents::PublishEntryService.new(
            content_type: T.must(@content_type),
            content_entry: T.must(@content_entry),
          ).call

          if result.success
            redirect_to admin_area_contents_collection_entry_path(
              content_type_id: T.must(@content_type).id,
              id: T.must(@content_entry).id,
            ), notice: 'コンテンツを公開しました'
          else
            redirect_to edit_admin_area_contents_collection_entry_path(
              content_type_id: T.must(@content_type).id,
              id: T.must(@content_entry).id,
            ), alert: result.errors.join(', ')
          end
        end

        def destroy
          result = unpublish_entry

          if result[:success]
            redirect_to admin_area_contents_collection_entry_path(
              content_type_id: T.must(@content_type).id,
              id: T.must(@content_entry).id,
            ), notice: '公開を取り消しました'
          else
            redirect_to admin_area_contents_collection_entry_path(
              content_type_id: T.must(@content_type).id,
              id: T.must(@content_entry).id,
            ), alert: result[:error]
          end
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

        sig { returns(T::Hash[Symbol, T.untyped]) }
        def unpublish_entry
          published_version = ContentEntry::Version.find_by(
            tenant_id: Tenant.current_id,
            content_type_id: T.must(@content_type).id,
            content_entry_id: T.must(@content_entry).id,
            status: ContentEntry::Version::STATUSES[:published],
          )

          unless published_version
            return { success: false, error: '公開中のバージョンがありません' }
          end

          published_version.update!(
            status: :unpublished,
            unpublished_at: Time.current,
          )

          { success: true }
        rescue StandardError => e
          { success: false, error: e.message }
        end
      end
    end
  end
end
