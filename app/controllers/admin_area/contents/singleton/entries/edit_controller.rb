# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Singleton
      module Entries
        class EditController < AdminArea::ApplicationController
          extend T::Sig

          def edit
            @content_type = ContentType.find(params[:content_type_id])
            @content_entry = @content_type.content_entries.first_or_initialize
          end

          def update
            @content_type = ContentType.find(params[:content_type_id])
            @content_entry = @content_type.content_entries.first_or_initialize

            if @content_entry.update(content_entry_params)
              redirect_to admin_area_contents_singleton_entry_path(
                content_type_id: @content_type.id,
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
