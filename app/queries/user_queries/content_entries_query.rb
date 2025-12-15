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

    # Filter by content type unique_name
    sig { params(content_type_unique_name: T.nilable(String)).returns(T.self_type) }
    def by_content_type(content_type_unique_name)
      return self if content_type_unique_name.blank?

      content_type = ContentType.find_by(unique_name: content_type_unique_name)
      return chain(@scope.none) if content_type.nil?

      chain(@scope.where(content_type_id: content_type.id))
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
    # Always filters content based on authorization:
    # - Public content (no tags): accessible to all
    # - Restricted content (with tags): only accessible to users with matching tags
    sig { override.returns(T::Array[EntityType]) }
    def resolve
      entries = T.unsafe(call.to_a)
      entries.select { |entry| self.class.authorized?(entry, user: @user) }
    end

    private

    sig { override.returns(ActiveRecord::Relation) }
    def base_scope
      ContentEntry.includes(:content_type, versions: { fields: [:content_type_field, :text, :richtext, :media_asset] })
    end
  end
end
