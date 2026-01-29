# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Singleton
      module Entries
        class EditController < AdminArea::ApplicationController
          extend T::Sig
          include AdminArea::Contents::Entries::FieldExtractable

          sig { returns(T.nilable(T::Hash[String, T.untyped])) }
          attr_reader :field_values

          before_action :set_content_type
          before_action :set_or_build_content_entry
          before_action :load_versions
          before_action :ensure_draft_version, only: [:edit]
          before_action :load_authorization_tags

          def edit
            @field_values = load_field_values
            load_selected_authorization_tag_id
            load_visibility
          end

          def update
            result = AdminArea::Contents::SaveEntryService.new(
              content_type: T.must(@content_type),
              content_entry: @content_entry,
              fields_params:,
              authorization_tag_ids: authorization_tag_ids_params,
              visibility: visibility_param,
              publication_date: publication_date_param,
            ).call

            if result.success
              redirect_to edit_admin_area_contents_singleton_entry_path(
                content_type_id: T.must(@content_type).id,
              ), notice: t('admin_area.contents.saved')
            else
              flash.now[:alert] = result.errors.join(', ')
              @field_values = fields_params
              @selected_authorization_tag_ids = authorization_tag_ids_params
              @visibility = visibility_param
              render :edit, status: :unprocessable_entity
            end
          end

          # Override: Singleton may have nil content_entry initially
          sig { override.returns(T.nilable(String)) }
          def content_entry_id_for_version
            @content_entry&.id
          end

          private

          sig { void }
          def set_or_build_content_entry
            @content_entry = T.let(
              T.must(@content_type).content_entries.first_or_initialize,
              T.nilable(ContentEntry),
            )
          end
        end
      end
    end
  end
end
