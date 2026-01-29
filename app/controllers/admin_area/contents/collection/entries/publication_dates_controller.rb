# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      module Entries
        class PublicationDatesController < AdminArea::ApplicationController
          extend T::Sig

          before_action :set_content_type
          before_action :set_content_entry

          sig { void }
          def update
            publication_date = params[:publication_date]
            entry = T.must(@content_entry)

            if entry.update(publication_date:)
              head :ok
            else
              render json: { errors: entry.errors.full_messages }, status: :unprocessable_entity
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
        end
      end
    end
  end
end
