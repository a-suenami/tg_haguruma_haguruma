# typed: true
# frozen_string_literal: true

class RulerArea::ContentModelsController < RulerArea::ApplicationController
  extend T::Sig
  before_action :set_tenant
  before_action :set_content_type, only: [:show, :update]

  sig { void }
  def index
    @collections = ContentType.collections.order(:created_at)
    @singletons = ContentType.singles.order(:created_at)
    @active_tab = params[:tab] || 'collections'
  end

  sig { void }
  def show
  end

  sig { void }
  def new
    @content_type = ContentType.new(is_collection: params[:type] != 'singleton')
  end

  sig { void }
  def create
    @content_type = ContentType.new(content_type_params)

    if @content_type.save
      redirect_to ruler_area_tenant_content_model_path(@tenant, @content_type), notice: t('ruler_area.content_models.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  sig { void }
  def update
    if @content_type.update(content_type_params)
      redirect_to ruler_area_tenant_content_model_path(@tenant, @content_type), notice: t('ruler_area.content_models.updated')
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  sig { void }
  def set_content_type
    @content_type = ContentType.find(params[:id])
  end

  sig { returns(ActionController::Parameters) }
  def content_type_params
    params.require(:content_type).permit(
      :display_name,
      :unique_name,
      :description,
      :is_collection,
      :tenant_id,
      fields_attributes: [
        :id,
        :label,
        :api_identifier,
        :description,
        :field_type,
        :required,
        :position,
        :tenant_id,
        :_destroy,
      ],
    )
  end
end
