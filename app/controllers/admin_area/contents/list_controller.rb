# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    class ListController < AdminArea::ApplicationController
      extend T::Sig

      def all
        @content_types = ContentType.all
        @content_entries = ContentEntry.all
      end

      def by_content_type
        @content_types = ContentType.all
        @content_type = ContentType.find(params[:content_type_id])

        if @content_type.is_collection
          # Collection type: show entries list
          @content_entries = @content_type.content_entries
        else
          # Singleton type: redirect to entry show page
          redirect_to admin_area_contents_singleton_entry_path(content_type_id: @content_type.id)
        end
      end
    end
  end
end
