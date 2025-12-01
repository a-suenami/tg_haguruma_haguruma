# typed: strict

module Eventbridge::Processors
  class IdPlatformProcessor < BaseProcessor
    extend T::Sig

    sig { override.params(message: Eventbridge::MessageParam).void }
    def process(message)
      detail = message.detail
      return unless detail.is_a?(Hash)

      case message.detail_type
      when 'Id Platform User'
        process_user(detail)
      when 'Id Platform Tag'
        process_tag(detail)
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

    sig { params(detail: T::Hash[T.untyped, T.untyped]).void }
    def process_tag(detail)
      submitted_at = begin
        Time.zone.parse(detail['submitted_at'])
      rescue StandardError
        nil
      end

      return unless submitted_at

      tenant_id = detail['tenant_id']
      tag_id = detail['tag_id']
      return unless tenant_id.present? && tag_id.present?

      case detail['action_code']
      when 'create', 'update'
        name = detail['name']
        return unless name.present?

        tag = ContentAuthorizationTags::UpsertByRemoteIdService.new(
          tenant_id:,
          remote_id: tag_id,
          name:,
          submitted_at:,
        ).execute

        if tag
          Rails.logger.info("IdPlatformProcessor: Successfully upserted tag #{tag_id} (name: #{name})")
        end
      when 'delete'
        success = ContentAuthorizationTags::DeleteByRemoteIdService.new(
          tenant_id:,
          remote_id: tag_id,
          submitted_at:,
        ).execute

        if success
          Rails.logger.info("IdPlatformProcessor: Successfully deleted tag #{tag_id}")
        end
      end
    end
  end
end
