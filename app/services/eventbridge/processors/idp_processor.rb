# typed: strict

module Eventbridge::Processors
  class IdpProcessor < BaseProcessor
    extend T::Sig

    sig { params(tenant_id: String).void }
    def initialize(tenant_id:)
      @tenant_id = tenant_id
    end

    sig { override.params(message: Eventbridge::MessageParam).void }
    def process(message)
      detail = message.detail
      return unless detail.is_a?(Hash)

      previous_tenant_id = Tenant.current_id
      begin
        Tenant.current_id = @tenant_id
        dispatch(message.detail_type, detail)
      ensure
        if previous_tenant_id
          Tenant.current_id = previous_tenant_id
        else
          RequestStore.store.delete(:current_tenant)
        end
      end
    end

    private

    sig { params(detail_type: String, detail: T::Hash[T.untyped, T.untyped]).void }
    def dispatch(detail_type, detail)
      handler = case detail_type
                when 'user_tag.created.v1'
                  Eventbridge::Handlers::UserTagCreatedHandler.new
                when 'tag.added.v1'
                  Eventbridge::Handlers::TagAddedHandler.new
                when 'tag.removed.v1'
                  Eventbridge::Handlers::TagRemovedHandler.new
      end

      if handler
        handler.handle(detail)
      else
        Rails.logger.warn("IdpProcessor: unknown detail_type=#{detail_type}")
      end
    end
  end
end
