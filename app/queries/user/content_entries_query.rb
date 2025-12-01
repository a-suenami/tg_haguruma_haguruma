# typed: strict
# frozen_string_literal: true

# ==============================================================================
# app - queries - user - content entries query
#
# Fetches published content entries for user-facing API
# ==============================================================================
module User
  class ContentEntriesQuery < ApplicationQuery
    extend T::Sig

    # Filter by content type
    sig { params(content_type_id: T.nilable(String)).returns(T.self_type) }
    def by_content_type(content_type_id)
      return self if content_type_id.blank?

      chain(@scope.where(content_type_id: content_type_id))
    end

    # Filter to only published entries
    sig { returns(T.self_type) }
    def published
      chain(@scope.joins(:versions).merge(ContentEntry::Version.published).distinct)
    end

    private

    sig { override.returns(ActiveRecord::Relation) }
    def base_scope
      ContentEntry.includes(:content_type, versions: { fields: [:content_type_field, :text, :richtext, :media_asset] })
    end
  end
end
