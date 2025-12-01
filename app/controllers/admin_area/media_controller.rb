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

  def create
    @media_asset = MediaAsset.new(media_asset_params)
    @media_asset.tenant_id = Tenant.current_id

    if params[:media_asset][:file].present?
      file = params[:media_asset][:file]
      @media_asset.mime_type = file.content_type
      @media_asset.media_type = MediaAsset.detect_media_type(file.content_type)
      @media_asset.metadata = {
        filename: file.original_filename,
        file_size: file.size,
        uploaded_at: Time.current.iso8601,
      }
      @media_asset.file.attach(file)
    end

    if @media_asset.save
      respond_to do |format|
        format.html { redirect_to admin_area_media_index_path, notice: 'メディアをアップロードしました' }
        format.json { render json: { id: @media_asset.id, url: url_for(@media_asset.file) }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @media_asset.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    if @media_asset.update(media_asset_update_params)
      redirect_to admin_area_media_index_path, notice: 'メディア情報を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @media_asset.destroy
    redirect_to admin_area_media_index_path, notice: 'メディアを削除しました'
  end

  # AJAX endpoint for file upload from editor
  def upload
    file = params[:file]
    return render json: { error: 'ファイルが必要です' }, status: :bad_request unless file

    media_asset = MediaAsset.new(
      tenant_id: Tenant.current_id,
      mime_type: file.content_type,
      media_type: MediaAsset.detect_media_type(file.content_type),
      metadata: {
        filename: file.original_filename,
        file_size: file.size,
        uploaded_at: Time.current.iso8601,
      },
    )
    media_asset.file.attach(file)

    if media_asset.save
      render json: {
        id: media_asset.id,
        url: url_for(media_asset.file),
        filename: media_asset.filename,
        media_type: media_asset.media_type,
      }
    else
      render json: { errors: media_asset.errors.full_messages }, status: :unprocessable_entity
    end
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
end
