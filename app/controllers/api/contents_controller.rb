# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - controllers - api - contents controller
# ==============================================================================
module Api
  class ContentsController < ApplicationController
    extend T::Sig

    sig { void }
    def index
      content_entries = User::ContentEntriesQuery.new
                                                 .with_associations
                                                 .by_content_type(params[:content_type_id])
                                                 .published
                                                 .call

      render json: ContentEntriesSerializer.new(content_entries).as_json
    end

    sig { void }
    def show
      content_entry = User::ContentEntriesQuery.new
                                               .with_associations
                                               .published
                                               .find(params[:id])

      render json: ContentEntrySerializer.new(content_entry).as_json
    end
  end
end
