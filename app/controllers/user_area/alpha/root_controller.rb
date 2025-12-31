# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class RootController < BaseController
      extend T::Sig

      sig { void }
      def index
        @kv_image_url = load_kv_image_url
      end

      private

      sig { returns(T.nilable(String)) }
      def load_kv_image_url
        content_type = ContentType.find_by(unique_name: 'kv', is_collection: false)
        return nil unless content_type

        entry = content_type.content_entries.first
        return nil unless entry

        version = entry.versions.published.first
        return nil unless version

        image_field = version.fields.find_by(field_type: :media_asset)
        image_field&.media_asset&.media_asset&.url
      end
    end
  end
end
