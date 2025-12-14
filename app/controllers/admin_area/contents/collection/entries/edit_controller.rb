# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      module Entries
        class EditController < AdminArea::ApplicationController
          extend T::Sig

          sig { returns(T.nilable(T::Hash[String, T.untyped])) }
          attr_reader :field_values

          before_action :set_content_type
          before_action :set_content_entry, only: [:edit, :update]
          before_action :build_content_entry, only: [:new, :create]
          before_action :load_versions, only: [:edit, :update]
          before_action :ensure_draft_version, only: [:edit]

          def new
            @field_values = {}
          end

          def edit
            @field_values = load_field_values
          end

          def create
            result = AdminArea::Contents::SaveEntryService.new(
              content_type: T.must(@content_type),
              content_entry: @content_entry,
              fields_params:,
            ).call

            if result.success
              redirect_to edit_admin_area_contents_collection_entry_path(
                content_type_id: T.must(@content_type).id,
                id: T.must(result.content_entry).id,
              ), notice: t('admin_area.contents.created')
            else
              flash.now[:alert] = result.errors.join(', ')
              @field_values = fields_params
              render :new, status: :unprocessable_entity
            end
          end

          def update
            result = AdminArea::Contents::SaveEntryService.new(
              content_type: T.must(@content_type),
              content_entry: @content_entry,
              fields_params:,
            ).call

            if result.success
              redirect_to edit_admin_area_contents_collection_entry_path(
                content_type_id: T.must(@content_type).id,
                id: T.must(@content_entry).id,
              ), notice: t('admin_area.contents.saved')
            else
              flash.now[:alert] = result.errors.join(', ')
              @field_values = fields_params
              render :edit, status: :unprocessable_entity
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

          sig { void }
          def load_versions
            @draft_version = T.let(
              ContentEntry::Version.find_by(
                tenant_id: Tenant.current_id,
                content_type_id: T.must(@content_type).id,
                content_entry_id: T.must(@content_entry).id,
                status: ContentEntry::Version::STATUSES[:draft],
              ),
              T.nilable(ContentEntry::Version),
            )

            @published_version = T.let(
              ContentEntry::Version.find_by(
                tenant_id: Tenant.current_id,
                content_type_id: T.must(@content_type).id,
                content_entry_id: T.must(@content_entry).id,
                status: ContentEntry::Version::STATUSES[:published],
              ),
              T.nilable(ContentEntry::Version),
            )
          end

          sig { void }
          def ensure_draft_version
            return if @draft_version.present?
            return if @published_version.blank?

            result = AdminArea::Contents::CreateDraftFromPublishedService.new(
              content_type: T.must(@content_type),
              content_entry: T.must(@content_entry),
              published_version: T.must(@published_version),
            ).call

            if result.success
              @draft_version = result.draft_version
            else
              flash.now[:alert] = result.errors.join(', ')
            end
          end

          sig { returns(T::Hash[String, T.untyped]) }
          def fields_params
            return {} unless params[:fields]

            params[:fields].permit!.to_h
          end

          sig { returns(T::Hash[String, T.untyped]) }
          def load_field_values
            version = @draft_version || @published_version
            return {} unless version

            field_values = {}

            T.must(@content_type).fields.each do |content_type_field|
              field = ContentEntry::Field.find_by(
                tenant_id: Tenant.current_id,
                content_type_id: T.must(@content_type).id,
                content_entry_id: T.must(@content_entry).id,
                version: version.version,
                content_type_field_id: content_type_field.id,
              )

              next unless field

              field_values[content_type_field.api_identifier] = extract_field_value(field)
            end

            field_values
          end

          sig { params(field: ContentEntry::Field).returns(T.untyped) }
          def extract_field_value(field)
            case field.field_type
            when 'text'
              field.text&.value
            when 'richtext'
              field.richtext&.value&.dig('html') || field.richtext&.value
            when 'media_asset'
              field.media_asset&.media_asset_id
            end
          end
        end
      end
    end
  end
end
