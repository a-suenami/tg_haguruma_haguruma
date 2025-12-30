# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      module Entries
        class SelectFieldsController < BaseFieldController
          extend T::Sig

          # PATCH /entries/:entry_id/select_fields/:api_identifier
          sig { void }
          def update
            result = AdminArea::Contents::SaveSelectFieldService.new(
              content_type: T.must(@content_type),
              content_entry: T.must(@content_entry),
              content_type_field: T.must(@content_type_field),
              value: params[:value],
            ).call

            render_result(result)
          end
        end
      end
    end
  end
end
