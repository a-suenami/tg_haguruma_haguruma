# typed: true
# frozen_string_literal: true

module AdminArea
  class ContentTypesController < AdminArea::ApplicationController
    extend T::Sig

    before_action :set_content_type, only: [:show, :edit, :update, :destroy]

    def index
      @content_types = ContentType.all.order(:display_name)
    end

    def show; end

    def new
      @content_type = ContentType.new
    end

    def edit; end

    def create
      @content_type = ContentType.new(content_type_params)
      @content_type.tenant_id = Tenant.current_id

      if @content_type.save
        redirect_to admin_area_content_type_path(@content_type),
                    notice: t('admin_area.content_types.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @content_type.update(content_type_params)
        redirect_to admin_area_content_type_path(@content_type),
                    notice: t('admin_area.content_types.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @content_type.content_entries.exists?
        redirect_to admin_area_content_types_path,
                    alert: t('admin_area.content_types.cannot_delete_with_contents')
      else
        @content_type.destroy
        redirect_to admin_area_content_types_path,
                    notice: t('admin_area.content_types.destroyed')
      end
    end

    private

    sig { void }
    def set_content_type
      @content_type = T.let(ContentType.find(params[:id]), T.nilable(ContentType))
    end

    sig { returns(ActionController::Parameters) }
    def content_type_params
      params.require(:content_type).permit(
        :unique_name,
        :display_name,
        :description,
        :is_collection,
      )
    end
  end
end
