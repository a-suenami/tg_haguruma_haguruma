# typed: true
# frozen_string_literal: true

class AdminArea::ContentEntriesController < AdminArea::ApplicationController
  extend T::Sig

  sig { void }
  def index
    if mobile_request?
      redirect_to content_types_admin_area_content_entries_path
      return
    end
  end

  sig { void }
  def edit
  end

  sig { void }
  def content_types
  end
end
