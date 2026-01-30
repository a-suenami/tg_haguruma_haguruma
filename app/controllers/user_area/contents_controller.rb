# typed: true
# frozen_string_literal: true

module UserArea
  class ContentsController < ApplicationController
    extend T::Sig

    # GET /contents
    sig { void }
    def index
      if params[:content_type_id].present?
        @content_type = ContentType.find(params[:content_type_id])
        @content_entries = UserQueries::ContentEntriesQuery.new
                             .by_content_type(@content_type.unique_name)
                             .authorized_for(current_user)
                             .resolve
      else
        @content_types = ContentType.all
      end
    end

    # GET /contents/:id
    sig { void }
    def show
      @content_entry = UserQueries::ContentEntriesQuery.new.resolve_find(params[:id])
      @content_type = @content_entry.content_type
    end
  end
end
