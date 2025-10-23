# typed: strict

module Eventbridge::Processors
  class CpiProcessor < BaseProcessor
    extend T::Sig

    sig { override.params(message: Eventbridge::MessageParam).void }
    def process(message)
      # CPI Userイベントのみを処理
      return unless message.detail_type == 'CPI User'

      detail = message.detail
      return unless detail.is_a?(Hash)
      return unless detail['tenant_id']

      process_user(detail)
    end

    private

    sig { params(detail: T::Hash[T.untyped, T.untyped]).void }
    def process_user(detail)
      # テナント管理がある場合はここでテナントコンテキストを設定
      # previous_tenant_id = Tenant.current_id
      # テナントコンテキストを設定（Multitenancyスコープが正しく動作するように）
      # これによりCompanionなどのモデルが適切なテナント内でのみ操作される
      # Tenant.current_id = detail['tenant_id'] if detail['tenant_id'].present?

      # CPIのpersonal_cフィールドをUIDとして扱い、ユーザーを検索
      # personal_cはCPIの個人識別子で、HAGURUMAではuidフィールドに対応
      # user = User.find_by(uid: detail['personal_c'])

      # ユーザーが見つからない場合はログを出力して処理をスキップ
      # unless user
      #   Rails.logger.warn("CpiProcessor: User not found for personal_c: #{detail['personal_c']} in tenant: #{detail['tenant_id']}")
      #   return
      # end

      # submitted_atフィールドを解析して、イベントの送信時刻を取得
      submitted_at = begin
        Time.zone.parse(detail['submitted_at'])
      rescue StandardError
        nil
      end

      # 必須のsubmitted_atフィールドが正しく解析できない場合はスキップ
      if submitted_at.nil?
        Rails.logger.warn("CpiProcessor: Invalid submitted_at timestamp: #{detail['submitted_at']}")
        return
      end

      # テナントIDの確認（防御的プログラミング）
      # EventBridgeイベントのtenant_idが現在のテナントと一致することを確認
      # if detail['tenant_id'].present? && Tenant.current_id.present? && detail['tenant_id'] != Tenant.current_id
      #   Rails.logger.warn("CpiProcessor: Tenant mismatch - event tenant: #{detail['tenant_id']}, current: #{Tenant.current_id}")
      #   return
      # end

      # action_codeに基づいて処理を分岐
      case detail['action_code']
      when 'delete'
        process_deletion(detail, submitted_at)
      when 'update'
        # 将来の拡張ポイント：更新処理を実装予定
        Rails.logger.warn("CpiProcessor: Update action not yet implemented for user #{detail['personal_c']}")
      else
        Rails.logger.warn("CpiProcessor: Unknown action_code: #{detail['action_code']}")
      end
    rescue StandardError => e
      # エラーが発生した場合はログに記録し、例外を再発生させる
      # これによりDLQ（Dead Letter Queue）への送信が可能になる
      Rails.logger.error("CpiProcessor: Error processing event - #{e.message}")
      raise
      # ensure
      #   Tenant.current_id = previous_tenant_id if defined?(Tenant)
    end

    sig { params(detail: T::Hash[T.untyped, T.untyped], submitted_at: ActiveSupport::TimeWithZone).void }
    def process_deletion(detail, _submitted_at)
      # deleted_atフィールドの日時を解析
      deleted_at = begin
        Time.zone.parse(detail['deleted_at'])
      rescue StandardError
        nil
      end

      # 必須のdeleted_atフィールドが正しく解析できない場合はスキップ
      if deleted_at.nil?
        Rails.logger.warn("CpiProcessor: Invalid deleted_at timestamp: #{detail['deleted_at']}")
        return
      end

      Rails.logger.info("CpiProcessor: Processing deletion for user #{detail['personal_c']} in tenant: #{detail['tenant_id']}")

      # Users::DeleteServiceを使用してユーザーの削除処理を実行
      # このサービスが以下を一括処理：
      # - idp_deleted_atの更新
      # - トークンの無効化
      # - 電話番号認証のリリース
      # - 同行者関係の削除
      # success = Users::DeleteService.new(user:).execute(
      #   deleted_at:,
      #   submitted_at:,
      # )
      #
      # if success
      #   Rails.logger.info("CpiProcessor: Successfully processed deletion for user #{user.uid} in tenant: #{detail['tenant_id']}")
      # end
    end
  end
end
