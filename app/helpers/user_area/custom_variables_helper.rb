# frozen_string_literal: true

module UserArea
  module CustomVariablesHelper
    # アクティブな変数をまとめて取得（キャッシュ対応しやすい形）
    def custom_variables
      @custom_variables ||= SiteCustomVariable.active.to_a
    end

    # Hash 形式で取得（キーでアクセスしやすい形）
    def custom_variables_hash
      @custom_variables_hash ||= custom_variables.index_by(&:unique_name)
    end
  end
end
