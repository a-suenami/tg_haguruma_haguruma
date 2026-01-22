# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      module Entries
        class MediaAssetFieldsController < BaseFieldController
          extend T::Sig

          # PATCH /entries/:entry_id/media_asset_fields/:api_identifier
          sig { void }
          def update
            result = AdminArea::Contents::SaveMediaAssetFieldService.new(
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
