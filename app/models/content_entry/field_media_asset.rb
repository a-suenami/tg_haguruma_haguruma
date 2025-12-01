# typed: false

# == Schema Information
#
# Table name: content_entry_field_media_assets
#
#  id             :bigint           not null, primary key
#  media_type     :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  media_asset_id :uuid             not null
#  tenant_id      :citext           not null
#
# Indexes
#
#  index_content_entry_field_media_assets_on_tenant_id_and_id  (tenant_id,id) UNIQUE
#
# Foreign Keys
#
#  fk_content_entry_field_media_assets_media_assets  ([tenant_id, media_type, media_asset_id] => media_assets[tenant_id, media_type, id])
#
class ContentEntry::FieldMediaAsset < ApplicationRecord
  enum :media_type, {
    image: 1,
    video: 2,
    audio: 3,
    document: 4,
  }

  validates :media_type, presence: true
  validates :s3_object_path, presence: true
end
