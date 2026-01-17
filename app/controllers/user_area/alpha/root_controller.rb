# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    class RootController < BaseController
      extend T::Sig

      sig { void }
      def index
        @kv_pc_image_url = load_kv_image_url('image_pc')
        @kv_sp_image_url = load_kv_image_url('image_sp')
        @banners = load_banners
        @news_entries = query_for(:news, limit: 4)
        @blog_entries = query_for(:blog, limit: 6, category: current_blog_category)
        @blog_categories = load_blog_categories
        @biography_entries = query_for(:biography)
      end

      sig { returns(T.nilable(String)) }
      def current_blog_category
        params[:blog_category]
      end
      helper_method :current_blog_category

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

      sig { params(content_type_key: Symbol, limit: T.nilable(Integer), category: T.nilable(String)).returns(T::Array[ContentEntry]) }
      def query_for(content_type_key, limit: nil, category: nil)
        query = UserQueries::ContentEntriesQuery.new
                  .by_content_type(content_type_key.to_s)
                  .published
                  .authorized_for(current_user)
                  .ordered_by_published_at
        query = query.by_select_option('category', category) if category.present?
        query = query.limit(limit) if limit
        query.resolve
      end

      sig { returns(T::Array[ContentType::FieldSelectOption]) }
      def load_blog_categories
        content_type = ContentType.find_by(unique_name: 'blog')
        return [] unless content_type

        content_type.fields.find_by(api_identifier: 'category')&.select&.options&.order(:position)&.to_a || []
      end

      sig { returns(T::Array[ContentEntry]) }
      def load_banners
        query_for(:banner)
      end
    end
  end
end
