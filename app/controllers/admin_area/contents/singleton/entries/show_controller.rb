# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Singleton
      module Entries
        class ShowController < AdminArea::ApplicationController
          extend T::Sig

          before_action :set_content_type
          before_action :set_content_entry
          before_action :load_versions

          def show
            render_not_found and return unless @published_version

            @field_values = load_field_values
          end

          private

          sig { void }
          def set_content_type
            @content_type = T.let(ContentType.find(params[:content_type_id]), T.nilable(ContentType))
          end

          sig { void }
          def set_content_entry
            @content_entry = T.let(
              T.must(@content_type).content_entries.first,
              T.nilable(ContentEntry),
            )
          end

          sig { void }
          def load_versions
            return unless @content_entry

            @published_version = T.let(
              ContentEntry::Version.find_by(
                tenant_id: Tenant.current_id,
                content_type_id: T.must(@content_type).id,
                content_entry_id: @content_entry.id,
                status: ContentEntry::Version::STATUSES[:published],
              ),
              T.nilable(ContentEntry::Version),
            )

            @draft_version = T.let(
              ContentEntry::Version.find_by(
                tenant_id: Tenant.current_id,
                content_type_id: T.must(@content_type).id,
                content_entry_id: @content_entry.id,
                status: ContentEntry::Version::STATUSES[:draft],
              ),
              T.nilable(ContentEntry::Version),
            )
          end

          sig { returns(T::Hash[String, T.untyped]) }
          def load_field_values
            # Show published version if available, otherwise draft
            version = @published_version || @draft_version
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
