# typed: true
# frozen_string_literal: true

module AdminArea
  module ContentTypes
    class FieldsController < AdminArea::ApplicationController
      extend T::Sig

      before_action :set_content_type
      before_action :set_field, only: [:edit, :update, :destroy]

      def new
        @field = T.must(@content_type).fields.build
      end

      def edit; end

      def create
        @field = T.must(@content_type).fields.build(field_params)
        @field.tenant_id = T.must(Tenant.current_id)

        if @field.save
          redirect_to admin_area_content_type_path(@content_type),
                      notice: t('admin_area.content_types.fields.created')
        else
          render :new, status: :unprocessable_entity
        end
      end


      def update
        if T.must(@field).update(field_params)
          redirect_to admin_area_content_type_path(@content_type),
                      notice: t('admin_area.content_types.fields.updated')
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        T.must(@field).destroy
        redirect_to admin_area_content_type_path(@content_type),
                    notice: t('admin_area.content_types.fields.destroyed')
      end

      def sort
        params[:field_ids].each_with_index do |id, index|
          ContentType::Field.where(id:, content_type_id: T.must(@content_type).id)
                            .update_all(position: index)
        end

        head :ok
      end

      private

      sig { void }
      def set_content_type
        @content_type = T.let(ContentType.find(params[:content_type_id]), T.nilable(ContentType))
      end

      sig { void }
      def set_field
        @field = T.let(
          T.must(@content_type).fields.find(params[:id]),
          T.nilable(ContentType::Field),
        )
      end

      sig { returns(ActionController::Parameters) }
      def field_params
        params.require(:content_type_field).permit(
          :api_identifier,
          :label,
          :field_type,
          :required,
          :description,
          :position,
        )
      end
    end
  end
end
