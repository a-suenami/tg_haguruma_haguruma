# typed: true
# frozen_string_literal: true

module UserArea
  module Alpha
    module ContentLoadable
      extend ActiveSupport::Concern
      extend T::Sig
      extend T::Helpers

      abstract!

      requires_ancestor { ActionController::Base }

      # Class methods module for source_content_type DSL
      module ClassMethods
        extend T::Sig

        sig { params(key: Symbol).void }
        def source_content_type(key)
          @source_content_type_key = key
        end

        sig { returns(T.nilable(Symbol)) }
        def source_content_type_key
          @source_content_type_key
        end
      end

      included do
        T.bind(self, T.class_of(ActionController::Base))
        helper_method :content_type, :categories, :current_category
      end

      # Abstract methods provided by ActionController::Base
      sig { abstract.returns(ActionController::Parameters) }
      def params; end

      sig { abstract.returns(T.nilable(User)) }
      def current_user; end

      private

      sig { returns(T.nilable(ContentType)) }
      def content_type
        @content_type ||= ContentType.find_by(unique_name: T.unsafe(self.class).source_content_type_key.to_s)
      end

      sig { params(field: String).returns(T::Array[ContentType::FieldSelectOption]) }
      def categories(field: 'category')
        content_type&.fields&.find_by(api_identifier: field)&.select&.options&.order(:position)&.to_a || []
      end

      sig { returns(T.nilable(String)) }
      def current_category
        params[:category]
      end

      sig { params(select_options: T::Hash[Symbol, T.nilable(String)], page: Integer, limit: Integer).returns(T::Array[ContentEntry]) }
      def query_entries(select_options: {}, page: 1, limit: 20)
        query = UserQueries::ContentEntriesQuery.new
                  .by_content_type(T.unsafe(self.class).source_content_type_key.to_s)
                  .published
                  .authorized_for(current_user)
                  .ordered_by_published_at

        select_options.each do |field, value|
          query = query.by_select_option(field.to_s, value) if value.present?
        end

        offset = (page - 1) * limit
        query = query.offset(offset).limit(limit)
        query.resolve
      end

      sig { params(id: String).returns(ContentEntry) }
      def find_entry(id)
        entry = ContentEntry.find(id)
        raise ActiveRecord::RecordNotFound unless UserQueries::ContentEntriesQuery.authorized?(entry, user: current_user)

        entry
      end

      # Find the single entry for a singleton ContentType (is_collection: false)
      sig { returns(ContentEntry) }
      def find_singleton_entry
        entry = content_type&.content_entries&.first
        raise ActiveRecord::RecordNotFound unless entry
        raise ActiveRecord::RecordNotFound unless UserQueries::ContentEntriesQuery.authorized?(entry, user: current_user)

        entry
      end
    end
  end
end
