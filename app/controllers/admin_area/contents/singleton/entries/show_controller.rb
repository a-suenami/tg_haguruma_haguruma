# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Singleton
      module Entries
        class ShowController < AdminArea::ApplicationController
          extend T::Sig
          include AdminArea::Contents::Entries::FieldExtractable

          before_action :set_content_type
          before_action :set_content_entry
          before_action :load_versions

          def show
            render_not_found and return unless @published_version

            @field_values = load_field_values
          end

          # Override: Singleton may have nil content_entry
          sig { override.returns(T.nilable(String)) }
          def content_entry_id_for_version
            @content_entry&.id
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
              T.must(@content_type).content_entries.first,
              T.nilable(ContentEntry),
            )
          end
        end
      end
    end
  end
end
