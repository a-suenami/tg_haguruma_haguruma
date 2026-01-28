# typed: true
# frozen_string_literal: true

module UserArea
  class PreviewController < UserArea::ApplicationController
    extend T::Sig

    # Skip basic auth for preview (token-based auth instead)
    skip_before_action :authenticate_with_basic_auth

    helper UserArea::ContentFieldHelper
    helper UserArea::ExternalUrlsHelper
    helper SvgHelper

    helper_method :content_authorized?, :published_version

    sig { void }
    def show
      @content_type = ContentType.find_by!(unique_name: params[:content_type])
      @entry = ContentEntry.find(params[:id])

      # Find version to preview
      @version = find_preview_version
      unless @version
        render plain: 'Preview not available or token expired', status: :forbidden
        return
      end

      render_preview_template
    end

    private

    # Preview always considers content as authorized
    sig { returns(T::Boolean) }
    def content_authorized?
      true
    end

    # Override published_version to return the preview version (may be draft)
    sig { params(_entry: T.nilable(ContentEntry)).returns(T.nilable(ContentEntry::Version)) }
    def published_version(_entry)
      @version
    end

    sig { returns(T.nilable(ContentEntry::Version)) }
    def find_preview_version
      token = params[:token]

      if token.present?
        # Token-based preview (for draft content)
        version = @entry.versions.find_by(preview_token: token)
        return nil if version.nil?
        return nil if version.preview_token_expires_at.nil?
        return nil if version.preview_token_expires_at < Time.current

        version
      else
        # No token: try published version
        @entry.versions.published.first
      end
    end

    sig { void }
    def render_preview_template
      # Determine template based on content type
      template_name = determine_template_name

      # Use alpha layout for now (can be made dynamic later)
      render template: template_name, layout: 'user_area/alpha/application'
    rescue ActionView::MissingTemplate
      render plain: "Preview template not found for '#{@content_type.unique_name}'", status: :not_found
    end

    sig { returns(String) }
    def determine_template_name
      # Extract template name from preview_url
      # e.g., "/news/:content_entry_id" → "news"
      # e.g., "/blog/:content_entry_id" → "blog"
      preview_url = @content_type.preview_url.to_s
      template_name = preview_url.split('/').compact_blank.first || @content_type.unique_name

      # For now, use alpha templates
      "user_area/alpha/#{template_name}/show"
    end
  end
end
