# typed: strict
# frozen_string_literal: true

# Transforms S3 object paths in Lexical richtext JSON to signed URLs
class RichtextUrlTransformer
  extend T::Sig

  sig { params(value: T.nilable(T::Hash[String, T.untyped]), public: T::Boolean).returns(T.nilable(T::Hash[String, T.untyped])) }
  def self.transform(value:, public: false)
    return nil if value.nil?

    new.transform(value: value.deep_dup, public:)
  end

  sig { params(value: T::Hash[String, T.untyped], public: T::Boolean).returns(T::Hash[String, T.untyped]) }
  def transform(value:, public:)
    deep_transform_media_nodes(node: value, public:)
  end

  private

  sig { params(node: T.untyped, public: T::Boolean).returns(T.untyped) }
  def deep_transform_media_nodes(node:, public:)
    return node unless node.is_a?(Hash)

    # Transform image and video nodes
    if %w[image video].include?(node['type'])
      media_asset_id = node['mediaAssetId']
      media_asset_url = get_media_asset_url_by_id(media_asset_id, public)
      node['src'] = media_asset_url if media_asset_url.present?
    end

    # Recursively transform children
    if node['children'].is_a?(Array)
      node['children'] = node['children'].map { |child| deep_transform_media_nodes(node: child, public:) }
    end

    # Transform root node
    if node['root'].is_a?(Hash)
      node['root'] = deep_transform_media_nodes(node: node['root'], public:)
    end

    node
  end

  sig { params(media_asset_id: T.nilable(String), public: T::Boolean).returns(T.nilable(String)) }
  def get_media_asset_url_by_id(media_asset_id, public)
    return nil if media_asset_id.blank?

    media_asset = MediaAsset.find_by(id: media_asset_id)
    return nil unless media_asset

    public ? media_asset.public_url : media_asset.url(purpose: :public)
  end
end
