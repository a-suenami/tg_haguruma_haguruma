# typed: true
# frozen_string_literal: true

module AdminArea
  module PreviewHelper
    extend T::Sig

    # Generate preview URL for published content (on user domain)
    # @param content_type [ContentType]
    # @param content_entry [ContentEntry]
    # @return [String, nil]
    sig { params(content_type: ContentType, content_entry: ContentEntry).returns(T.nilable(String)) }
    def generate_published_preview_url(content_type, content_entry)
      preview_url = content_type.preview_url
      return nil if preview_url.blank?

      path = preview_url
               .gsub(':content_entry_id', content_entry.id.to_s)
               .gsub(':content_type_id', content_type.id.to_s)

      build_user_area_url(path)
    end

    # Generate preview URL for draft content with token (on user domain)
    # @param content_type [ContentType]
    # @param content_entry [ContentEntry]
    # @param version [ContentEntry::Version]
    # @return [String, nil]
    sig do
      params(
        content_type: ContentType,
        content_entry: ContentEntry,
        version: ContentEntry::Version,
      ).returns(T.nilable(String))
    end
    def generate_draft_preview_url(content_type, content_entry, version)
      return nil if content_type.preview_url.blank?

      # Generate or refresh preview token
      token = ensure_preview_token(version)

      path = "/preview/#{content_type.unique_name}/#{content_entry.id}"
      build_user_area_url(path, params: [['token', token]])
    end

    private

    # Build full URL for user area domain
    sig { params(path: String, params: T::Array[[String, String]]).returns(String) }
    def build_user_area_url(path, params: [])
      tenant = Tenant.current
      return path if tenant.nil?
      return path if tenant.user_page_domain.blank?

      # Use current request port if available (for dev environment)
      # T.unsafe needed because `request` is available at runtime via ActionView context
      port = T.unsafe(self).respond_to?(:request) ? T.unsafe(self).request.port : nil
      tenant.user_page_path(path, params:, port:)
    end

    sig { params(version: ContentEntry::Version).returns(String) }
    def ensure_preview_token(version)
      # If token exists and not expired, reuse it
      if version.preview_token.present? &&
         version.preview_token_expires_at.present? &&
         T.must(version.preview_token_expires_at) > Time.current
        return T.must(version.preview_token)
      end

      # Generate new token
      token = SecureRandom.urlsafe_base64(32)
      version.update!(
        preview_token: token,
        preview_token_expires_at: 24.hours.from_now,
      )
      token
    end
  end
end
