# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - serializers - content entry serializer
# ==============================================================================
class ContentEntrySerializer < ApplicationSerializer
  extend T::Sig

  sig { override.returns(T::Hash[Symbol, T.untyped]) }
  def serializable_hash
    content_entry = T.cast(@resource, ContentEntry)
    published_version = content_entry.versions.find(&:published?)

    {
      content_type: content_type_hash(content_entry.content_type),
      fields: fields_hash(published_version),
      published_at: published_version&.published_at,
      created_at: content_entry.created_at,
      updated_at: content_entry.updated_at,
    }
  end

  private

  sig { params(content_type: ContentType).returns(T::Hash[Symbol, T.untyped]) }
  def content_type_hash(content_type)
    {
      id: content_type.id,
      unique_name: content_type.unique_name,
      display_name: content_type.display_name,
      is_collection: content_type.is_collection,
    }
  end

  sig { params(version: T.nilable(ContentEntry::Version)).returns(T::Hash[String, T.untyped]) }
  def fields_hash(version)
    return {} if version.nil?

    version.fields.each_with_object({}) do |field, hash|
      api_identifier = field.content_type_field.api_identifier
      hash[api_identifier] = field_value(field)
    end
  end

  sig { params(field: ContentEntry::Field).returns(T.untyped) }
  def field_value(field)
    case field.field_type
    when 'text'
      field.text&.value
    when 'richtext'
      field.richtext&.value
    when 'media_asset'
      media_asset_hash(field.media_asset)
    end
  end

  sig { params(media_asset: T.nilable(ContentEntry::FieldMediaAsset)).returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def media_asset_hash(media_asset)
    return nil if media_asset.nil?

    {
      media_type: media_asset.media_type,
      s3_object_path: media_asset.s3_object_path,
    }
  end
end
