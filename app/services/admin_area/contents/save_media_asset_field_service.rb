# typed: strict
# frozen_string_literal: true

module AdminArea
  module Contents
    class SaveMediaAssetFieldService < BaseSaveFieldService
      extend T::Sig

      private

      sig { override.returns(String) }
      def expected_field_type
        'media_asset'
      end

      sig { override.params(field: ContentEntry::Field).void }
      def save_field_value(field)
        return if @value.blank?

        media_asset = MediaAsset.find_by(id: @value)
        return unless media_asset

        if field.media_asset
          field.media_asset.update!(
            media_type: media_asset.media_type,
            media_asset_id: media_asset.id,
          )
        else
          field_media_asset = ContentEntry::FieldMediaAsset.create!(
            tenant_id: Tenant.current_id,
            media_type: media_asset.media_type,
            media_asset_id: media_asset.id,
          )
          field.media_asset = field_media_asset
        end
        field.save!
      end
    end
  end
end
