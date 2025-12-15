# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      module Entries
        class EditController < AdminArea::ApplicationController
          extend T::Sig
          include AdminArea::Contents::Entries::FieldExtractable

          sig { returns(T.nilable(T::Hash[String, T.untyped])) }
          attr_reader :field_values

          before_action :set_content_type
          before_action :set_content_entry, only: [:edit, :update]
          before_action :build_content_entry, only: [:new, :create]
          before_action :load_versions, only: [:edit, :update]
          before_action :ensure_draft_version, only: [:edit]
          before_action :load_authorization_tags

          def new
            @field_values = {}
            @selected_authorization_tag_ids = []
            @is_public = true
          end

          def edit
            @field_values = load_field_values
            load_selected_authorization_tag_id
            load_is_public
          end

          def create
            result = AdminArea::Contents::SaveEntryService.new(
              content_type: T.must(@content_type),
              content_entry: @content_entry,
              fields_params:,
              authorization_tag_ids: authorization_tag_ids_params,
              is_public: is_public_param,
            ).call

            if result.success
              redirect_to edit_admin_area_contents_collection_entry_path(
                content_type_id: T.must(@content_type).id,
                id: T.must(result.content_entry).id,
              ), notice: t('admin_area.contents.created')
            else
              flash.now[:alert] = result.errors.join(', ')
              @field_values = fields_params
              @selected_authorization_tag_ids = authorization_tag_ids_params
              @is_public = is_public_param
              render :new, status: :unprocessable_entity
            end
          end

          def update
            result = AdminArea::Contents::SaveEntryService.new(
              content_type: T.must(@content_type),
              content_entry: @content_entry,
              fields_params:,
              authorization_tag_ids: authorization_tag_ids_params,
              is_public: is_public_param,
            ).call

            if result.success
              redirect_to edit_admin_area_contents_collection_entry_path(
                content_type_id: T.must(@content_type).id,
                id: T.must(@content_entry).id,
              ), notice: t('admin_area.contents.saved')
            else
              flash.now[:alert] = result.errors.join(', ')
              @field_values = fields_params
              @selected_authorization_tag_ids = authorization_tag_ids_params
              @is_public = is_public_param
              render :edit, status: :unprocessable_entity
            end
          end

          private

          sig { void }
          def set_content_entry
            @content_entry = T.let(
              T.must(@content_type).content_entries.find(params[:id]),
              T.nilable(ContentEntry),
            )
          end

          sig { void }
          def build_content_entry
            @content_entry = T.let(
              T.must(@content_type).content_entries.build,
              T.nilable(ContentEntry),
            )
          end
        end
      end
    end
  end
end
