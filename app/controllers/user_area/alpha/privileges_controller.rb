# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class PrivilegesController < BaseController
      extend T::Sig

      include ContentLoadable
      source_content_type :faq

      sig { void }
      def show
        @kv_pc_image_url = load_kv_image_url('image_pc')
        @kv_sp_image_url = load_kv_image_url('image_sp')
        @faq_entries = query_entries(page: 1, limit: 100)
      end

      private

      sig { params(api_identifier: String).returns(T.nilable(String)) }
      def load_kv_image_url(api_identifier)
        content_type = ContentType.find_by(unique_name: 'kv', is_collection: false)
        return nil unless content_type

        entry = content_type.content_entries.first
        return nil unless entry

        version = entry.versions.published.first
        return nil unless version

        content_type_field = content_type.fields.find_by(api_identifier:)
        return nil unless content_type_field

        image_field = version.fields.find_by(content_type_field_id: content_type_field.id)
        image_field&.media_asset&.media_asset&.url
      end
    end
  end
end
