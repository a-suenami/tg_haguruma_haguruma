# typed: strict

module Multitenancy
  extend ActiveSupport::Concern
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ApplicationRecord }

  included do
    T.bind(self, T.class_of(ApplicationRecord))
    belongs_to :tenant, optional: false
  end

  module ClassMethods
    extend T::Sig

    sig { returns(T.nilable(ActiveRecord::Relation)) }
    def default_scope
      T.bind(self, ActiveRecord::Querying)
      where(tenant_id: RequestStore.store[:current_tenant]) if RequestStore.store[:current_tenant].present?
    end
  end

  sig { returns(Tenant) }
  def tenant!
    T.unsafe(self).tenant
  end
end
