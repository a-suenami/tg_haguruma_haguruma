# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Singleton
      module Entries
        class PublicationDatesController < AdminArea::ApplicationController
          extend T::Sig
          include AdminArea::Contents::Entries::FieldExtractable

          before_action :set_content_type
          before_action :set_content_entry
          before_action :set_draft_version

          sig { void }
          def update
            version = T.must(@draft_version)

            if version.update(custom_published_at: custom_published_at_param)
              head :ok
            else
              render json: { errors: version.errors.full_messages }, status: :unprocessable_entity
            end
          end

          private

          sig { void }
          def set_content_entry
            @content_entry = T.let(
              T.must(@content_type).content_entries.first,
              T.nilable(ContentEntry),
            )
          end

          sig { void }
          def set_draft_version
            return unless @content_entry

            @draft_version = T.let(
              T.must(@content_entry).versions.find_by(status: ContentEntry::Version::STATUSES[:draft]),
              T.nilable(ContentEntry::Version),
            )

            return if @draft_version

            render json: { errors: ['No draft version found'] }, status: :not_found
          end
        end
      end
    end
  end
end
