# typed: true
# frozen_string_literal: true

# ==============================================================================
# app - queries - user_queries - content entries query
#
# Fetches published content entries for user-facing API
# ==============================================================================
module UserQueries
  class ContentEntriesQuery < ApplicationQuery
    extend T::Sig

    EntityType = type_member { { fixed: ContentEntry } }

    class ContentAuthorizationError < StandardError; end

    class << self
      extend T::Sig

      # Check if user is authorized to access the entry
      # Content without tags is accessible to all
      # Content with tags requires user to have at least one matching tag
      sig { params(entry: ContentEntry, user: T.nilable(User)).returns(T::Boolean) }
      def authorized?(entry, user:)
        published_version = entry.versions.find(&:published?)
        return false unless published_version

        content_tags = published_version.content_authorization_tags

        # Content without tags is accessible to all
        return true if content_tags.empty?

        # Content with tags requires authenticated user with matching tag
        return false if user.nil?

        user_tag_ids = user.content_authorization_tags.pluck(:id)
        content_tag_ids = content_tags.pluck(:id)
        user_tag_ids.intersect?(content_tag_ids)
      end
    end

    sig { void }
    def initialize
      super
      @user = T.let(nil, T.nilable(User))
    end

    # Filter by content type
    sig { params(content_type_id: T.nilable(String)).returns(T.self_type) }
    def by_content_type(content_type_id)
      return self if content_type_id.blank?

      chain(@scope.where(content_type_id:))
    end

    # Filter to only published entries
    sig { returns(T.self_type) }
    def published
      chain(@scope.joins(:versions).merge(ContentEntry::Version.published).distinct)
    end

    # Filter by authorization for a user
    sig { params(user: T.nilable(User)).returns(T.self_type) }
    def authorized_for(user)
      @user = user
      self
    end

    # Override resolve to apply authorization filtering
    sig { override.returns(T::Array[EntityType]) }
    def resolve
      entries = T.unsafe(call.to_a)
      return entries unless @user || authorization_filtering_enabled?

      entries.select { |entry| self.class.authorized?(entry, user: @user) }
    end

    private

    sig { override.returns(ActiveRecord::Relation) }
    def base_scope
      ContentEntry.includes(:content_type, versions: { fields: [:content_type_field, :text, :richtext, :media_asset] })
    end

    sig { returns(T::Boolean) }
    def authorization_filtering_enabled?
      !@user.nil?
    end
  end
end
