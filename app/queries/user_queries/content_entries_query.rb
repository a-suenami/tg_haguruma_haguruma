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

      # Check if user is authorized to access the entry based on visibility level
      # - public: Anyone can access (including anonymous users)
      # - authenticated: Only logged-in users can access
      # - restricted: Only users with matching authorization tags can access
      sig { params(entry: ContentEntry, user: T.nilable(User)).returns(T::Boolean) }
      def authorized?(entry, user:)
        published_version = entry.versions.find(&:published?)
        return false unless published_version

        case published_version.visibility
        when 'public'
          true
        when 'authenticated'
          user.present?
        when 'restricted'
          return false if user.nil?

          content_tags = published_version.content_authorization_tags
          return false if content_tags.empty?

          user_tag_ids = user.content_authorization_tags.pluck(:id)
          content_tag_ids = content_tags.pluck(:id)
          user_tag_ids.intersect?(content_tag_ids)
        else
          false
        end
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
