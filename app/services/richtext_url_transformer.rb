# typed: strict
# frozen_string_literal: true

# Transforms S3 object paths in Lexical richtext JSON to signed URLs
class RichtextUrlTransformer
  extend T::Sig

  sig { params(value: T.nilable(T::Hash[String, T.untyped])).returns(T.nilable(T::Hash[String, T.untyped])) }
  def self.transform(value)
    return nil if value.nil?

    new.transform(value.deep_dup)
  end

  sig { params(value: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
  def transform(value)
    deep_transform_media_nodes(value)
  end

  private

  sig { params(node: T.untyped).returns(T.untyped) }
  def deep_transform_media_nodes(node)
    return node unless node.is_a?(Hash)

    # Transform image and video nodes
    if %w[image video].include?(node['type']) && node['src'].present?
      node['src'] = generate_signed_url(node['src'])
    end

    # Recursively transform children
    if node['children'].is_a?(Array)
      node['children'] = node['children'].map { |child| deep_transform_media_nodes(child) }
    end

    # Transform root node
    if node['root'].is_a?(Hash)
      node['root'] = deep_transform_media_nodes(node['root'])
    end

    node
  end

  sig { params(s3_path: String).returns(String) }
  def generate_signed_url(s3_path)
    # Already a full URL (legacy data or external URL)
    return s3_path if s3_path.start_with?('http')

    uploader = MediaAsset::Uploader.new
    # Detect media type from path
    media_type = s3_path.include?('/videos/') ? :video : :image
    uploader.url_for(s3_path, purpose: :public, media_type:)
  end
end
