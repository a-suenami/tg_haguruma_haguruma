# typed: false
# frozen_string_literal: true

# ==============================================================================
# app - serializers - application serializer
# ==============================================================================
class ApplicationSerializer
  extend T::Sig

  sig { params(resource: T.untyped).void }
  def initialize(resource)
    @resource = T.let(resource, T.untyped)
  end

  sig { params(_options: T::Hash[T.untyped, T.untyped]).returns(T::Hash[Symbol, T.untyped]) }
  def as_json(_options = {})
    {
      data: {
        id: @resource.id.to_s,
        type: T.must(self.class.name).demodulize.underscore.gsub(/_serializer$/, ''),
        attributes: serializable_hash,
      },
    }
  end

  sig { params(_options: T::Hash[T.untyped, T.untyped]).returns(String) }
  def to_json(_options = {})
    as_json.to_json
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def serializable_hash
    {}
  end

  class << self
    extend T::Sig

    sig { params(names: Symbol).void }
    def attributes(*names)
      define_method(:serializable_hash) do
        result = {}
        names.each do |name|
          result[name] = @resource.public_send(name)
        end
        result
      end
    end
  end
end
