# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      module Entries
        class ShowController < AdminArea::ApplicationController
          extend T::Sig
          include AdminArea::Contents::Entries::FieldExtractable

          before_action :set_content_type
          before_action :set_content_entry
          before_action :load_versions

          def show
            unless @published_version
              # No published version - redirect to edit page
              redirect_to edit_admin_area_contents_collection_entry_path(
                content_type_id: T.must(@content_type).id,
                id: T.must(@content_entry).id,
              )
              return
            end

            @field_values = load_field_values
            load_selected_authorization_tags
            load_visibility
          end

          # Override: Show prioritizes published version
          sig { override.returns(T.nilable(ContentEntry::Version)) }
          def version_for_field_values
            @published_version || @draft_version
          end

          # Override: Show extracts HTML from richtext
          sig { override.params(field: ContentEntry::Field).returns(T.untyped) }
          def extract_richtext_value(field)
            field.richtext&.value&.dig('html') || field.richtext&.value
          end

          private

          sig { void }
          def set_content_entry
            @content_entry = T.let(
              T.must(@content_type).content_entries.find(params[:id]),
              T.nilable(ContentEntry),
            )
          end
        end
      end
    end
  end
end
