# typed: true
# frozen_string_literal: true

module AdminArea
  module Contents
    module Entries
      module FieldExtractable
        extend T::Sig
        extend T::Helpers

        requires_ancestor { ActionController::Base }

        sig { void }
        def set_content_type
          @content_type = T.let(ContentType.find(params[:content_type_id]), T.nilable(ContentType))
        end

        sig { void }
        def load_versions
          return unless content_entry_id_for_version

          @draft_version = T.let(
            ContentEntry::Version.find_by(
              tenant_id: Tenant.current_id,
              content_type_id: T.must(@content_type).id,
              content_entry_id: content_entry_id_for_version,
              status: ContentEntry::Version::STATUSES[:draft],
            ),
            T.nilable(ContentEntry::Version),
          )

          @published_version = T.let(
            ContentEntry::Version.find_by(
              tenant_id: Tenant.current_id,
              content_type_id: T.must(@content_type).id,
              content_entry_id: content_entry_id_for_version,
              status: ContentEntry::Version::STATUSES[:published],
            ),
            T.nilable(ContentEntry::Version),
          )
        end

        sig { void }
        def ensure_draft_version
          return if @draft_version.present?
          return if @published_version.blank?

          result = AdminArea::Contents::CreateDraftFromPublishedService.new(
            content_type: T.must(@content_type),
            content_entry: T.must(@content_entry),
            published_version: T.must(@published_version),
          ).call

          if result.success
            @draft_version = result.draft_version
          else
            flash.now[:alert] = result.errors.join(', ')
          end
        end

        sig { returns(T::Hash[String, T.untyped]) }
        def fields_params
          return {} unless params[:fields]

          params[:fields].permit!.to_h
        end

        sig { returns(T::Hash[String, T.untyped]) }
        def load_field_values
          version = version_for_field_values
          return {} unless version

          field_values = {}

          T.must(@content_type).fields.each do |content_type_field|
            field = ContentEntry::Field.find_by(
              tenant_id: Tenant.current_id,
              content_type_id: T.must(@content_type).id,
              content_entry_id: T.must(@content_entry).id,
              version: version.version,
              content_type_field_id: content_type_field.id,
            )

            next unless field

            field_values[content_type_field.api_identifier] = extract_field_value(field)
          end

          field_values
        end

        sig { params(field: ContentEntry::Field).returns(T.untyped) }
        def extract_field_value(field)
          case field.field_type
          when 'text'
            field.text&.value
          when 'richtext'
            extract_richtext_value(field)
          when 'media_asset'
            field.media_asset&.media_asset_id
          end
        end

        # Override this method in Show controllers to extract HTML
        sig { params(field: ContentEntry::Field).returns(T.untyped) }
        def extract_richtext_value(field)
          field.richtext&.value
        end

        # Override this method if @content_entry can be nil
        sig { returns(T.nilable(String)) }
        def content_entry_id_for_version
          T.must(@content_entry).id
        end

        sig { returns(T.nilable(ContentEntry::Version)) }
        def version_for_field_values
          @draft_version || @published_version
        end

        sig { void }
        def load_authorization_tags
          @authorization_tags = T.let(
            ContentAuthorizationTag.all.to_a,
            T.nilable(T::Array[ContentAuthorizationTag]),
          )
        end

        sig { void }
        def load_selected_authorization_tag_ids
          version = version_for_field_values
          @selected_authorization_tag_ids = T.let(
            version&.content_authorization_tags&.pluck(:id) || [],
            T.nilable(T::Array[String]),
          )
        end

        sig { void }
        def load_selected_authorization_tag_id
          version = version_for_field_values
          @selected_authorization_tag_id = T.let(
            version&.content_authorization_tags&.first&.id,
            T.nilable(String),
          )
        end

        sig { void }
        def load_selected_authorization_tags
          version = version_for_field_values
          @selected_authorization_tags = T.let(
            version&.content_authorization_tags&.to_a || [],
            T.nilable(T::Array[ContentAuthorizationTag]),
          )
        end

        sig { void }
        def load_visibility
          version = version_for_field_values
          visibility_value = version&.visibility
          @visibility = T.let(
            visibility_value || 'public',
            T.nilable(String),
          )
        end

        sig { returns(T::Array[String]) }
        def authorization_tag_ids_params
          Array(params[:authorization_tag_ids]).compact_blank
        end

        sig { returns(String) }
        def visibility_param
          params[:visibility] || 'public'
        end
      end
    end
  end
end
