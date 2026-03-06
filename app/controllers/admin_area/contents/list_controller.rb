# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    class ListController < AdminArea::ApplicationController
      extend T::Sig

      def all
        @content_types = ContentType.all
        @content_entries = ContentEntry.includes(:versions).order(created_at: :desc)
        @show_all = true
      end

      def by_content_type
        @content_types = ContentType.all
        @content_type = ContentType.find(params[:content_type_id])

        if @content_type.is_collection
          # Collection type: show entries list
          @content_entries = @content_type.content_entries.includes(:versions).order(created_at: :desc)
        else
          # Singleton type: redirect to show (will redirect to edit if no published version)
          redirect_to admin_area_contents_singleton_entry_path(content_type_id: @content_type.id)
        end
      end
    end
  end
end
