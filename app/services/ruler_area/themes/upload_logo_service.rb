# typed: strict
# frozen_string_literal: true

module RulerArea
  module Themes
    class UploadLogoService
      extend T::Sig

      class Result < T::Struct
        const :success, T::Boolean
        const :media_asset, T.nilable(MediaAsset)
        const :url, T.nilable(String)
        const :error, T.nilable(String)
      end

      sig { params(tenant_id: String).void }
      def initialize(tenant_id:)
        @tenant_id = tenant_id
        @uploader = T.let(MediaAsset::Uploader.new, MediaAsset::Uploader)
        @copy_service = T.let(MediaAssets::CopyService.new, MediaAssets::CopyService)
      end

      # Upload a new logo file (private) then copy to public
      sig { params(file: ActionDispatch::Http::UploadedFile).returns(Result) }
      def upload_new(file:)
        cloudfront_signer = MediaAsset::CloudFrontSigner.new

        # Upload to private storage
        result = @uploader.upload(file:, tenant_id: @tenant_id)
        media_asset = result[:media_asset]

        # Copy to public storage
        public_path = @copy_service.copy_to_public(media_asset:)

        Result.new(
          success: true,
          media_asset:,
          url: cloudfront_signer.public_url(public_path),
          error: nil,
        )
      rescue StandardError => e
        Result.new(
          success: false,
          media_asset: nil,
          url: nil,
          error: e.message,
        )
      end

      # Use an existing media asset as logo
      # Creates a public copy if it doesn't exist
      sig { params(media_asset: MediaAsset).returns(Result) }
      def use_existing(media_asset:)
        cloudfront_signer = MediaAsset::CloudFrontSigner.new

        public_path = if media_asset.public?
          T.must(media_asset.public_s3_object_path)
        else
          @copy_service.copy_to_public(media_asset:)
        end

        Result.new(
          success: true,
          media_asset:,
          url: cloudfront_signer.public_url(public_path),
          error: nil,
        )
      rescue StandardError => e
        Result.new(
          success: false,
          media_asset: nil,
          url: nil,
          error: e.message,
        )
      end
    end
  end
end
