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

    # Filter to only published entries (each entry has at most one published version)
    sig { returns(T.self_type) }
    def published
      chain(@scope.joins(:versions).merge(ContentEntry::Version.published))
    end

    # Filter by authorization for a user using SQL JOIN
    # - Anonymous users: only public content (visibility = 0)
    # - Logged-in users: content where user has matching authorization tags
    sig { params(user: T.nilable(User)).returns(T.self_type) }
    def authorized_for(user)
      @user = user

      if user.nil?
        # Anonymous: only public content
        chain(
          @scope.joins(:versions)
            .merge(ContentEntry::Version.published)
            .where(content_entry_versions: { visibility: 0 }),
        )
      else
        # Logged-in: filter by matching tags via INNER JOIN
        chain(
          @scope
            .joins(versions: { content_entry_authorizations: { content_authorization_tag: :user_tags } })
            .merge(ContentEntry::Version.published)
            .where(user_tags: { user_id: user.id })
            .distinct,
        )
      end
    end

    # Filter by select field option
    # field_identifier: the api_identifier of the ContentType::Field
    # option_unique_name: the unique_name of the ContentType::FieldSelectOption
    sig { params(field_identifier: String, option_unique_name: T.nilable(String)).returns(T.self_type) }
    def by_select_option(field_identifier, option_unique_name)
      return self if option_unique_name.blank?

      chain(
        @scope
          .joins(versions: { fields: [:content_type_field, { select: { selections: :option } }] })
          .where(content_type_fields: { api_identifier: field_identifier })
          .where(content_type_field_select_options: { unique_name: option_unique_name })
          .merge(ContentEntry::Version.published),
      )
    end

    # Order by published_at descending
    sig { returns(T.self_type) }
    def ordered_by_published_at
      chain(
        @scope
          .joins(:versions)
          .merge(ContentEntry::Version.published)
          .order('content_entry_versions.published_at DESC'),
      )
    end

    # Apply offset
    sig { params(count: Integer).returns(T.self_type) }
    def offset(count)
      chain(@scope.offset(count))
    end

    # Apply limit
    sig { params(count: Integer).returns(T.self_type) }
    def limit(count)
      chain(@scope.limit(count))
    end

    # Resolve the query - authorization is now handled in SQL via authorized_for
    sig { override.returns(T::Array[EntityType]) }
    def resolve
      T.unsafe(call.to_a)
    end

    private

    sig { override.returns(ActiveRecord::Relation) }
    def base_scope
      ContentEntry.includes(:content_type, versions: { fields: [:content_type_field, :text, :richtext, :media_asset] })
    end
  end
end
