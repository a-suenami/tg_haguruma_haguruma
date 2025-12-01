# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - queries - content entries query
#
# Fetches published content entries with their latest published version
# ==============================================================================
class ContentEntriesQuery < ApplicationQuery
  extend T::Sig

  sig { params(content_type_id: T.nilable(String)).void }
  def initialize(content_type_id: nil)
    @content_type_id = content_type_id
    super()
  end

  sig { override.returns(ActiveRecord::Relation) }
  def call
    scope = ContentEntry.includes(:content_type, versions: { fields: [:content_type_field, :text, :richtext, :media_asset] })
    scope = scope.where(content_type_id: @content_type_id) if @content_type_id.present?
    scope = scope.joins(:versions).merge(ContentEntry::Version.published).distinct
    scope
  end
end
