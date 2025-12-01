# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      module Entries
        class BaseFieldController < AdminArea::ApplicationController
          extend T::Sig

          before_action :set_content_type
          before_action :set_content_entry
          before_action :set_content_type_field

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
          def set_content_type_field
            @content_type_field = T.let(
              T.must(@content_type).fields.find_by!(api_identifier: params[:api_identifier]),
              T.nilable(ContentType::Field),
            )
          end

          sig { params(result: AdminArea::Contents::BaseSaveFieldService::Result).void }
          def render_result(result)
            if result.success
              render json: {
                success: true,
                saved_at: Time.current.iso8601,
                field: T.must(@content_type_field).api_identifier,
              }
            else
              render json: {
                success: false,
                errors: result.errors,
                field: T.must(@content_type_field).api_identifier,
              }, status: :unprocessable_entity
            end
          end
        end
      end
    end
  end
end
