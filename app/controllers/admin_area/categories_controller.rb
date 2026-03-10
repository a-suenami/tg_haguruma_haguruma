# typed: true
# frozen_string_literal: true

class AdminArea::CategoriesController < AdminArea::ApplicationController
  extend T::Sig

  require_feature :admin_category

  sig { void }
  def index
    # TODO: カテゴリーモデル作成後に実装
    # @categories = Category.where(tenant_id: Tenant.current_id).order(:name)
    @categories = []
  end

  def show
    redirect_to admin_area_categories_path
  end

  def new
    # @category = Category.new
  end

  def edit
    redirect_to admin_area_categories_path
  end

  def create
    # TODO: カテゴリーモデル作成後に実装
    redirect_to admin_area_categories_path, alert: t('admin_area.categories.feature_in_progress')
  end


  def update
    redirect_to admin_area_categories_path, alert: t('admin_area.categories.feature_in_progress')
  end

  def destroy
    redirect_to admin_area_categories_path, alert: t('admin_area.categories.feature_in_progress')
  end
end
