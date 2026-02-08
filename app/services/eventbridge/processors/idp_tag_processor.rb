# typed: strict

module Eventbridge::Processors
  class IdpTagProcessor < BaseProcessor
    extend T::Sig

    sig { override.params(message: Eventbridge::MessageParam).void }
    def process(message)
      tenant_id = extract_tenant_id(message.source)
      return if tenant_id.blank?

      detail = message.detail
      return unless detail.is_a?(Hash)

      previous_tenant_id = Tenant.current_id
      Tenant.current_id = tenant_id

      dispatch(message.detail_type, detail)
    ensure
      Tenant.current_id = previous_tenant_id if previous_tenant_id
    end

    private

    sig { params(source: String).returns(T.nilable(String)) }
    def extract_tenant_id(source)
      match = source.match(%r{\Acom\.twogate\.idp/([^/]+)/})
      match&.[](1)
    end

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

      handler&.handle(detail)
    end
  end
end
