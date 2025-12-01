# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      module Entries
        class TextFieldsController < BaseFieldController
          extend T::Sig

          # PATCH /entries/:entry_id/text_fields/:api_identifier
          sig { void }
          def update
            result = AdminArea::Contents::SaveTextFieldService.new(
              content_type: T.must(@content_type),
              content_entry: T.must(@content_entry),
              content_type_field: T.must(@content_type_field),
              value: params[:value].to_s,
            ).call

            render_result(result)
          end
        end
      end
    end
  end
end
