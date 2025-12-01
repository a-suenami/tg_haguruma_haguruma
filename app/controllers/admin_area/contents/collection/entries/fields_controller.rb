# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      module Entries
        class FieldsController < AdminArea::ApplicationController
          extend T::Sig

          before_action :set_content_type
          before_action :set_content_entry
          before_action :set_content_type_field

          # PATCH /entries/:entry_id/fields/:api_identifier
          sig { void }
          def update
            result = AdminArea::Contents::SaveFieldService.new(
              content_type: T.must(@content_type),
              content_entry: T.must(@content_entry),
              content_type_field: T.must(@content_type_field),
              value: field_value,
            ).call

            if result.success
              render json: {
                success: true,
                saved_at: Time.current.iso8601,
                field: @content_type_field.api_identifier,
              }
            else
              render json: {
                success: false,
                errors: result.errors,
                field: @content_type_field.api_identifier,
              }, status: :unprocessable_entity
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
          def set_content_type_field
            @content_type_field = T.let(
              T.must(@content_type).fields.find_by!(api_identifier: params[:api_identifier]),
              T.nilable(ContentType::Field),
            )
          end

          sig { returns(T.untyped) }
          def field_value
            params[:value]
          end
        end
      end
    end
  end
end
