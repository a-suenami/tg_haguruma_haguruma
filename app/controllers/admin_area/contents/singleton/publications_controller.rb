# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Singleton
      class PublicationsController < AdminArea::ApplicationController
        extend T::Sig

        def create
          @content_type = ContentType.find(params[:content_type_id])
          @content_entry = @content_type.content_entries.first

          # TODO: Implement publication logic
          # Create a new version and mark it as published

          redirect_to admin_area_contents_singleton_entry_path(
            content_type_id: @content_type.id,
          )
        end
      end
    end
  end
end
