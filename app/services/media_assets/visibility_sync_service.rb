# typed: strict
# frozen_string_literal: true

module MediaAssets
  class VisibilitySyncService
    extend T::Sig

    sig { params(version: ContentEntry::Version).void }
    def initialize(version:)
      @version = version
      @copy_service = T.let(::MediaAssets::CopyService.new, ::MediaAssets::CopyService)
    end

    # Sync media assets to public folder if the version has public visibility
    # This should be called after a version is published
    sig { void }
    def call
      # Only sync for public visibility content
      return unless @version.visibility_public?

      # Collect all media assets from the version's fields
      media_assets = collect_media_assets

      # Copy each asset to public folder
      media_assets.each do |media_asset|
        copy_to_public(media_asset)
      end
    end

    private

    sig { returns(T::Array[::MediaAsset]) }
    def collect_media_assets
      media_assets = T.let([], T::Array[::MediaAsset])

      @version.fields.each do |field|
        media_assets.concat(extract_media_assets_from_field(field))
      end

      media_assets.uniq(&:id)
    end

    sig { params(field: ContentEntry::Field).returns(T::Array[::MediaAsset]) }
    def extract_media_assets_from_field(field)
      case field.field_type
      when 'media_asset'
        extract_from_media_asset_field(field)
      when 'richtext'
        extract_from_richtext_field(field)
      else
        []
      end
    end

    sig { params(field: ContentEntry::Field).returns(T::Array[::MediaAsset]) }
    def extract_from_media_asset_field(field)
      field_media_asset = field.media_asset
      return [] unless field_media_asset

      media_asset = field_media_asset.media_asset
      return [] unless media_asset

      [media_asset]
    end

    sig { params(field: ContentEntry::Field).returns(T::Array[::MediaAsset]) }
    def extract_from_richtext_field(field)
      richtext = field.richtext
      return [] unless richtext

      value = richtext.value
      return [] unless value.is_a?(Hash)

      media_asset_ids = extract_media_asset_ids_from_node(value)
      find_media_assets_by_ids(media_asset_ids)
    end

    sig { params(node: T.untyped).returns(T::Array[String]) }
    def extract_media_asset_ids_from_node(node)
      media_asset_ids = T.let([], T::Array[String])
      return media_asset_ids unless node.is_a?(Hash)

      # Extract s3ObjectPath from image and video nodes
      if %w[image video].include?(node['type']) && node['mediaAssetId'].present?
        media_asset_ids << node['mediaAssetId'].to_s
      end

      # Recursively process children
      if node['children'].is_a?(Array)
        node['children'].each do |child|
          media_asset_ids.concat(extract_media_asset_ids_from_node(child))
        end
      end

      # Process root node
      if node['root'].is_a?(Hash)
        media_asset_ids.concat(extract_media_asset_ids_from_node(node['root']))
      end

      media_asset_ids
    end

    sig { params(ids: T::Array[String]).returns(T::Array[::MediaAsset]) }
    def find_media_assets_by_ids(ids)
      return [] if ids.empty?

      ::MediaAsset.where(id: ids).to_a
    end

    sig { params(media_asset: ::MediaAsset).void }
    def copy_to_public(media_asset)
      # Skip if asset already has a public copy
      return if media_asset.public?

      @copy_service.copy_to_public(media_asset:)
    end
  end
end
