# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Collection
      module Entries
        class EditController < AdminArea::ApplicationController
          extend T::Sig

          def new
            @content_type = T.let(ContentType.find(params[:content_type_id]), T.nilable(ContentType))
            entry = T.cast(T.must(@content_type).content_entries.build, ContentEntry)
            @content_entry = T.let(entry, T.nilable(ContentEntry))
          end

          def edit
            @content_type = T.let(ContentType.find(params[:content_type_id]), T.nilable(ContentType))
            @content_entry = T.let(T.must(@content_type).content_entries.find(params[:id]), T.nilable(ContentEntry))
          end

          def create
            @content_type = T.let(ContentType.find(params[:content_type_id]), T.nilable(ContentType))
            entry = T.cast(T.must(@content_type).content_entries.build(content_entry_params), ContentEntry)
            @content_entry = T.let(entry, T.nilable(ContentEntry))

            if T.must(@content_entry).save
              redirect_to admin_area_contents_collection_entry_path(
                content_type_id: T.must(@content_type).id,
                id: T.must(@content_entry).id,
              )
            else
              render :new
            end
          end


          def update
            @content_type = T.let(ContentType.find(params[:content_type_id]), T.nilable(ContentType))
            @content_entry = T.let(T.must(@content_type).content_entries.find(params[:id]), T.nilable(ContentEntry))

            if T.must(@content_entry).update(content_entry_params)
              redirect_to admin_area_contents_collection_entry_path(
                content_type_id: T.must(@content_type).id,
                id: T.must(@content_entry).id,
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
