# typed: true
# frozen_string_literal: true

class AdminArea::MediaController < AdminArea::ApplicationController
  extend T::Sig

  before_action :set_media_asset, only: [:show, :edit, :update, :destroy]

  sig { void }
  def index
    @media_assets = MediaAsset.order(created_at: :desc)

    # Filter by media type
    if params[:type].present? && MediaAsset.media_types.key?(params[:type])
      @media_assets = @media_assets.where(media_type: params[:type])
    end

    # Search by filename
    if params[:q].present?
      @media_assets = @media_assets.where("metadata->>'filename' ILIKE ?", "%#{params[:q]}%")
    end
  end

  def show; end

  def new
    @media_asset = MediaAsset.new
  end

  def edit; end

  def create
    @media_asset = MediaAsset.new(media_asset_params)
    @media_asset.tenant_id = T.must(Tenant.current_id)

    if params[:media_asset][:file].present?
      file = params[:media_asset][:file]

      # MIME タイプ検証（マジックナンバーチェック含む）
      begin
        MimeTypeValidator.validate!(file)
      rescue MimeTypeValidator::InvalidMimeTypeError => e
        @media_asset.errors.add(:file, e.message)
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: { errors: [e.message] }, status: :unprocessable_entity }
        end
        return
      end

      @media_asset.mime_type = file.content_type
      @media_asset.media_type = MediaAsset.detect_media_type(file.content_type)
      @media_asset.file_size_bytes = file.size
      @media_asset.s3_object_path = generate_s3_object_path(file)
      @media_asset.metadata = {
        original_filename: file.original_filename,
      }
      @media_asset.file.attach(file)
    end

    if @media_asset.save
      respond_to do |format|
        format.html { redirect_to admin_area_media_path, notice: t('admin_area.media.uploaded') }
        format.json { render json: { id: @media_asset.id, url: url_for(@media_asset.file) }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @media_asset.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end


  def update
    if T.must(@media_asset).update(media_asset_update_params)
      redirect_to admin_area_media_path, notice: t('admin_area.media.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    T.must(@media_asset).destroy
    redirect_to admin_area_media_path, notice: t('admin_area.media.destroyed')
  end

  # AJAX endpoint for file upload from editor (uploads to S3 and returns CloudFront URL)
  sig { void }
  def upload
    file = params[:file]
    return render json: { error: 'ファイルが必要です' }, status: :bad_request unless file

    uploader = MediaAsset::Uploader.new
    result = uploader.upload(
      file:,
      tenant_id: T.must(Tenant.current_id),
    )

    render json: {
      id: result[:media_asset].id,
      url: result[:url],
      s3_object_path: result[:s3_object_path],
      original_filename: result[:media_asset].original_filename,
      media_type: result[:media_asset].media_type,
    }
  rescue MimeTypeValidator::InvalidMimeTypeError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error("Media upload failed: #{e.message}")
    render json: { error: 'アップロードに失敗しました' }, status: :internal_server_error
  end

  private

  sig { void }
  def set_media_asset
    @media_asset = T.let(MediaAsset.find(params[:id]), T.nilable(MediaAsset))
  end

  sig { returns(ActionController::Parameters) }
  def media_asset_params
    params.require(:media_asset).permit(:file)
  end

  sig { returns(ActionController::Parameters) }
  def media_asset_update_params
    params.require(:media_asset).permit(:metadata)
  end

  sig { params(file: ActionDispatch::Http::UploadedFile).returns(String) }
  def generate_s3_object_path(file)
    timestamp = Time.current.strftime('%Y/%m/%d')
    uuid = SecureRandom.uuid
    extension = File.extname(file.original_filename)

    "#{Tenant.current_id}/#{timestamp}/#{uuid}#{extension}"
  end
end
