# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class RootController < BaseController
      extend T::Sig

      sig { void }
      def index
        @kv_image_url = load_kv_image_url
        @news_entries = query_for(:news, limit: 3)
        @blog_entries = query_for(:blog, limit: 5)
        @biography_entries = query_for(:biography)
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

      sig { params(content_type_key: Symbol, limit: T.nilable(Integer)).returns(T::Array[ContentEntry]) }
      def query_for(content_type_key, limit: nil)
        query = UserQueries::ContentEntriesQuery.new
                  .by_content_type(content_type_key.to_s)
                  .published
                  .authorized_for(current_user)
                  .ordered_by_published_at
        query = query.limit(limit) if limit
        query.resolve
      end
    end
  end
end
