# typed: false
# frozen_string_literal: true

module RulerArea
  class CustomVariablesController < ApplicationController
    include RulerArea::TenantSettable

    before_action :set_tenant
    before_action :set_custom_variable, only: %i[edit update destroy edit_value update_value]

    def index
      # TODO: 実際のモデルに置き換え。今はUIプレビュー用のダミーデータ
      @custom_variables = dummy_variables
    end

    def new
      @custom_variable = OpenStruct.new(key: '', type: 'boolean', description: '')
    end

    def create
      # TODO: 実際の保存処理を実装
      redirect_to ruler_area_tenant_custom_variables_path(@tenant), notice: 'カスタム変数を追加しました。'
    end

    def edit; end

    def update
      # TODO: 実際の保存処理を実装
      redirect_to ruler_area_tenant_custom_variables_path(@tenant), notice: 'カスタム変数を更新しました。'
    end

    def destroy
      # TODO: 実際のアーカイブ処理を実装
      redirect_to ruler_area_tenant_custom_variables_path(@tenant), notice: 'カスタム変数をアーカイブしました。'
    end

    def edit_value; end

    def update_value
      # TODO: 実際の保存処理を実装
      redirect_to ruler_area_tenant_custom_variables_path(@tenant), notice: '値を更新しました。'
    end

    private

    def set_custom_variable
      # TODO: 実際のモデルに置き換え
      @custom_variable = dummy_variables.find { |v| v[:id].to_s == params[:id] }
      @custom_variable = OpenStruct.new(@custom_variable) if @custom_variable
    end

    def dummy_variables
      [
        { id: 1, key: 'enable_new_feature', type: 'boolean', value: true, description: '新機能を有効にする' },
        { id: 2, key: 'campaign_end_date', type: 'datetime', value: '2025-12-31T23:59', description: 'キャンペーン終了日時' },
        { id: 3, key: 'announcement_message', type: 'text', value: 'メンテナンスのお知らせ', description: 'お知らせメッセージ' },
      ]
    end
  end
end
