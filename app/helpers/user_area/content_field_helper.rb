# typed: true
# frozen_string_literal: true

module UserArea
  module ContentFieldHelper
    extend T::Sig
    include LexicalHelper

    # Get text value from a field
    sig { params(field: T.nilable(ContentEntry::Field)).returns(String) }
    def render_text_field(field)
      return '' if field.nil?

      field.text&.value || ''
    end

    # Render richtext field as HTML
    sig { params(field: T.nilable(ContentEntry::Field)).returns(String) }
    def render_richtext_field(field)
      return '' if field.nil?

      json = RichtextUrlTransformer.transform(field.richtext&.value)
      return '' if json.nil?

      lexical_to_html(json)
    end

    # Get signed URL for media asset field
    sig { params(field: T.nilable(ContentEntry::Field)).returns(T.nilable(String)) }
    def media_asset_url(field)
      return nil if field.nil?

      field_media_asset = field.media_asset
      return nil if field_media_asset.nil?

      media_asset = field_media_asset.media_asset
      return nil if media_asset.nil?

      uploader = MediaAsset::Uploader.new
      uploader.url_for(
        media_asset.s3_object_path,
        purpose: :public,
        media_type: field_media_asset.media_type.to_sym,
      )
    end

    # Get selected options from a select field
    sig { params(field: T.nilable(ContentEntry::Field)).returns(T::Array[ContentType::FieldSelectOption]) }
    def selected_options(field)
      return [] if field.nil?

      select = field.select
      return [] if select.nil?

      select.selected_options.to_a
    end

    # Get the first selected option (useful for single-select fields like category)
    sig { params(field: T.nilable(ContentEntry::Field)).returns(T.nilable(ContentType::FieldSelectOption)) }
    def selected_option(field)
      selected_options(field).first
    end

    # Helper to find a field by api_identifier from a version
    sig { params(version: T.nilable(ContentEntry::Version), api_identifier: String).returns(T.nilable(ContentEntry::Field)) }
    def field_by_identifier(version, api_identifier)
      return nil if version.nil?

      version.fields.find { |f| f.content_type_field&.api_identifier == api_identifier }
    end

    # Format date for display
    sig { params(datetime: T.nilable(Time)).returns(String) }
    def format_content_date(datetime)
      return '' if datetime.nil?

      datetime.strftime('%Y.%m.%d')
    end

    # Get published version from an entry
    sig { params(entry: T.nilable(ContentEntry)).returns(T.nilable(ContentEntry::Version)) }
    def published_version(entry)
      return nil if entry.nil?

      entry.versions.find(&:published?)
    end
  end
end
