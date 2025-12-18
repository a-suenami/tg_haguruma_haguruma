# typed: true
# frozen_string_literal: true

module AdminArea
  module PreviewHelper
    extend T::Sig

    sig { params(content_entry: ContentEntry).returns(T.nilable(String)) }
    def preview_url(content_entry)
      frontend_url = Settings.preview.frontend_url
      return nil if frontend_url.blank?

      token = Preview::TokenService.generate(
        content_entry_id: content_entry.id,
        tenant_id: content_entry.tenant_id,
      )

      uri = URI.parse(frontend_url)
      query_params = URI.decode_www_form(uri.query || '')
      query_params << ['content_entry_id', content_entry.id]
      query_params << ['preview_token', token]
      uri.query = URI.encode_www_form(query_params)

      uri.to_s
    end
  end
end
