# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Singleton
      module Entries
        class ShowController < AdminArea::ApplicationController
          extend T::Sig

          def show
            @content_type = ContentType.find(params[:content_type_id])
            @content_entry = @content_type.content_entries.first
          end
        end
      end
    end
  end
end
