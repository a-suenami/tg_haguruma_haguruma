# typed: strict

module Eventbridge::Processors
  class IdPlatformProcessor < BaseProcessor
    extend T::Sig

    sig { override.params(message: Eventbridge::MessageParam).void }
    def process(message)
      case message.detail_type
      when 'Id Platform User'
        detail = message.detail
        return unless detail.is_a?(Hash)

        process_user(detail)
      end
    end

    private

    sig { params(detail: T::Hash[T.untyped, T.untyped]).void }
    def process_user(detail)
      # テナント管理がある場合はここでテナントコンテキストを設定
      # previous_tenant_id = Tenant.current_id
      # tenant_id = detail['tenant_id']
      # Tenant.current_id = tenant_id if tenant_id.present?

      # ユーザーの検索と処理
      # user = User.find_by(uid: detail['user_id'])
      submitted_at = begin
        Time.zone.parse(detail['submitted_at'])
      rescue
        nil
      end

      return unless submitted_at

      case detail['action_code']
      when 'update'
        # ユーザー更新処理
        Rails.logger.info("IdPlatformProcessor: Update action received for user #{detail['user_id']}")
        # user_params = Auth::IdPlatform::GenerateUserParamFromIdpUserService.new(idp_user: detail['user']).execute
        # Users::UpdateService.new(user:).execute(user_params:, update_if_record_older_than: submitted_at)
      when 'delete'
        # ユーザー削除処理
        Rails.logger.info("IdPlatformProcessor: Delete action received for user #{detail['user_id']}")
        # success = Users::DeleteService.new(user:).execute(
        #   deleted_at: Time.current,
        #   submitted_at:,
        # )
        #
        # if success
        #   Rails.logger.info("IdPlatformProcessor: Successfully processed deletion for user #{user.uid}")
        # end
      end
      # ensure
      #   Tenant.current_id = previous_tenant_id if defined?(Tenant)
    end
  end
end
