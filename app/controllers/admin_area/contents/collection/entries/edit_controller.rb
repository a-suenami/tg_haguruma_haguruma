# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      module Entries
        class EditController < AdminArea::ApplicationController
          extend T::Sig

          def new
            @content_type = ContentType.find(params[:content_type_id])
            @content_entry = @content_type.content_entries.build
          end

          def create
            @content_type = ContentType.find(params[:content_type_id])
            @content_entry = @content_type.content_entries.build(content_entry_params)

            if @content_entry.save
              redirect_to admin_area_contents_collection_entry_path(
                content_type_id: @content_type.id,
                id: @content_entry.id,
              )
            else
              render :new
            end
          end

          def edit
            @content_type = ContentType.find(params[:content_type_id])
            @content_entry = @content_type.content_entries.find(params[:id])
          end

          def update
            @content_type = ContentType.find(params[:content_type_id])
            @content_entry = @content_type.content_entries.find(params[:id])

            if @content_entry.update(content_entry_params)
              redirect_to admin_area_contents_collection_entry_path(
                content_type_id: @content_type.id,
                id: @content_entry.id,
              )
            else
              render :edit
            end
          end

          private

          def content_entry_params
            params.require(:content_entry).permit(:tenant_id, :content_type_id)
          end
        end
      end
    end
  end
end
