# frozen_string_literal: true

# ==============================================================================
# Key Visual Content Type (Singleton)
# ==============================================================================

Rails.logger.debug '🖼️ Seeding Key Visual Content Type...'

# dev-tenant にキービジュアルコンテンツタイプを作成
Tenant.current_id = 'dev-tenant'

# -----------------------------------------------------------------------------
# Content Type: Key Visual (Singleton)
# -----------------------------------------------------------------------------
kv_type = ContentType.find_or_initialize_by(unique_name: 'kv')
kv_type.assign_attributes(
  display_name: 'キービジュアル',
  description: 'トップページのキービジュアル画像',
  is_collection: false, # シングルトン
)

if kv_type.save
  Rails.logger.debug { "  ✅ ContentType: #{kv_type.display_name} (#{kv_type.unique_name})" }

  # PC用画像フィールド
  image_pc_field = kv_type.fields.find_or_initialize_by(api_identifier: 'image_pc')
  image_pc_field.assign_attributes(
    label: 'PC用画像',
    field_type: :media_asset,
    required: true,
    position: 0,
  )
  image_pc_field.media_asset ||= ContentType::FieldMediaAsset.create!
  image_pc_field.save!

  # SP用画像フィールド
  image_sp_field = kv_type.fields.find_or_initialize_by(api_identifier: 'image_sp')
  image_sp_field.assign_attributes(
    label: 'SP用画像',
    field_type: :media_asset,
    required: true,
    position: 1,
  )
  image_sp_field.media_asset ||= ContentType::FieldMediaAsset.create!
  image_sp_field.save!

  Rails.logger.debug { "    - Fields: #{kv_type.fields.count}" }
else
  Rails.logger.debug { "  ❌ Failed: #{kv_type.errors.full_messages.join(', ')}" }
end

# sample テナントにも作成
Tenant.current_id = 'sample'

sample_kv_type = ContentType.find_or_initialize_by(unique_name: 'kv')
sample_kv_type.assign_attributes(
  display_name: 'キービジュアル',
  description: 'トップページのキービジュアル画像',
  is_collection: false,
)

if sample_kv_type.save
  Rails.logger.debug { "  ✅ ContentType: #{sample_kv_type.display_name} (#{sample_kv_type.unique_name}) [sample]" }

  # PC用画像フィールド
  image_pc_field = sample_kv_type.fields.find_or_initialize_by(api_identifier: 'image_pc')
  image_pc_field.assign_attributes(
    label: 'PC用画像',
    field_type: :media_asset,
    required: true,
    position: 0,
  )
  image_pc_field.media_asset ||= ContentType::FieldMediaAsset.create!
  image_pc_field.save!

  # SP用画像フィールド
  image_sp_field = sample_kv_type.fields.find_or_initialize_by(api_identifier: 'image_sp')
  image_sp_field.assign_attributes(
    label: 'SP用画像',
    field_type: :media_asset,
    required: true,
    position: 1,
  )
  image_sp_field.media_asset ||= ContentType::FieldMediaAsset.create!
  image_sp_field.save!

  Rails.logger.debug { "    - Fields: #{sample_kv_type.fields.count}" }
else
  Rails.logger.debug { "  ❌ Failed: #{sample_kv_type.errors.full_messages.join(', ')}" }
end
