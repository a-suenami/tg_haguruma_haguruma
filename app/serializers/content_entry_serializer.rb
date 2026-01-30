# typed: true
# frozen_string_literal: true

# ==============================================================================
# app - serializers - content entry serializer
# ==============================================================================
# == Schema Information
#
# Table name: content_entries
#
#  id               :uuid             not null, primary key
#  publication_date :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  content_type_id  :uuid             not null
#  tenant_id        :citext           not null
#
# Indexes
#
#  index_content_entries_on_tenant_id_and_content_type_id_and_id  (tenant_id,content_type_id,id) UNIQUE
#  index_content_entries_on_tenant_id_and_id                      (tenant_id,id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  ([tenant_id, content_type_id] => content_types[tenant_id, id])
#
class ContentEntrySerializer < ApplicationSerializer
  extend T::Sig

  sig { override.params(_options: T::Hash[T.untyped, T.untyped]).returns(T::Hash[Symbol, T.untyped]) }
  def as_json(_options = {})
    content_entry = T.cast(@resource, ContentEntry)
    published_version = T.must(content_entry.versions.find(&:published?))

    {
      data: {
        id: content_entry.id.to_s,
        content_type: content_type_hash(T.must(content_entry.content_type)),
        attributes: attributes_hash(published_version),
        version: published_version.version,
        published_at: published_version.published_at,
      },
    }
  end

  private

  sig { params(content_type: ContentType).returns(T::Hash[Symbol, T.untyped]) }
  def content_type_hash(content_type)
    {
      unique_name: content_type.unique_name,
      display_name: content_type.display_name,
      is_collection: content_type.is_collection,
    }
  end

  sig { params(version: ContentEntry::Version).returns(T::Hash[String, T.untyped]) }
  def attributes_hash(version)
    version.fields.each_with_object({}) do |field, hash|
      content_type_field = T.must(field.content_type_field)
      api_identifier = content_type_field.api_identifier
      hash[api_identifier] = attribute_value(field, content_type_field)
    end
  end

  sig { params(field: ContentEntry::Field, content_type_field: ContentType::Field).returns(T::Hash[Symbol, T.untyped]) }
  def attribute_value(field, content_type_field)
    base = {
      type: field.field_type,
      field: {
        unique_name: content_type_field.api_identifier,
        display_name: content_type_field.label,
      },
    }

    case field.field_type
    when 'text'
      base.merge(text: { value: field.text&.value })
    when 'richtext'
      base.merge(richtext: { json_value: RichtextUrlTransformer.transform(field.richtext&.value) })
    when 'media_asset'
      base.merge(media_asset: media_asset_hash(field.media_asset))
    when 'select_field'
      base.merge(select_field: select_field_hash(field.select, content_type_field))
    else
      base
    end
  end

  sig do
    params(
      field_select: T.nilable(ContentEntry::FieldSelect),
      content_type_field: ContentType::Field,
    ).returns(T.nilable(T::Hash[Symbol, T.untyped]))
  end
  def select_field_hash(field_select, content_type_field)
    return nil if field_select.nil?

    selected_option_ids = field_select.selected_option_ids
    options = content_type_field.select&.options&.where(id: selected_option_ids) || []

    {
      selected_options: options.map do |option|
        {
          id: option.id,
          api_identifier: option.api_identifier,
          display_name: option.display_name,
        }
      end,
    }
  end

  sig { params(field_media_asset: T.nilable(ContentEntry::FieldMediaAsset)).returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def media_asset_hash(field_media_asset)
    return nil if field_media_asset.nil?

    uploader = MediaAsset::Uploader.new
    url = uploader.url_for(
      field_media_asset.s3_object_path,
      purpose: :public,
      media_type: field_media_asset.media_type.to_sym,
    )

    {
      media_type: field_media_asset.media_type,
      url:,
    }
  end
end
