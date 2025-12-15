# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      module Entries
        class AuthorizationsController < AdminArea::ApplicationController
          extend T::Sig

          before_action :set_content_type
          before_action :set_content_entry
          before_action :load_draft_version

          sig { void }
          def update
            result = AdminArea::Contents::SetAuthorizationTagsService.new(
              content_entry: T.must(@content_entry),
              version: T.must(@draft_version),
              authorization_tag_ids:,
              is_public: public_param?,
            ).call

            if result.success
              head :ok
            else
              render json: { errors: result.errors }, status: :unprocessable_entity
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
              T.must(@content_type).content_entries.find(params[:entry_id]),
              T.nilable(ContentEntry),
            )
          end

          sig { void }
          def load_draft_version
            @draft_version = T.let(
              ContentEntry::Version.find_by(
                tenant_id: Tenant.current_id,
                content_type_id: T.must(@content_type).id,
                content_entry_id: T.must(@content_entry).id,
                status: ContentEntry::Version::STATUSES[:draft],
              ),
              T.nilable(ContentEntry::Version),
            )

            render json: { error: 'Draft version not found' }, status: :not_found unless @draft_version
          end

          sig { returns(T::Array[String]) }
          def authorization_tag_ids
            tag_id = params[:authorization_tag_id]
            tag_id.present? ? [tag_id] : []
          end

          sig { returns(T::Boolean) }
          def public_param?
            params[:is_public] == true || params[:is_public] == 'true' || params[:is_public] == '1'
          end
        end
      end
    end
  end
end
