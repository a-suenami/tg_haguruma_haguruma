# typed: true

# ==============================================================================
# spec - request helper
# ==============================================================================
module RequestHelper
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { Kernel }

  included do
    Dir[Rails.root.join('spec/requests/schemas/**/*.rb')].each { |f| require f }

    T.bind(self, T.untyped)
    let(:current_tenant) { create(:tenant, id: :kenshiyonezu, name: 'Yonezu Kenshi', openlogi_enabled: true) }
  end

  sig { returns(ActionDispatch::TestResponse) }
  def response = super

  def body_hash
    ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(response.body)) if response.body.present?
  end

  def error_code
    body_hash.dig(:error, :code)&.to_sym if response.body.present?
  end

  def error_message
    body_hash.dig(:error, :message) if response.body.present?
  end

  def body_data
    data = body_hash[:data]

    data.define_singleton_method :attributes_map do
      T.bind(self, T::Array[T.untyped])
      self.map do |datum|
        yield ActiveSupport::InheritableOptions.new(datum[:attributes])
      end
    end

    data
  end

  def data_attributes
    ActiveSupport::InheritableOptions.new(body_data[:attributes])
  end

  def body_included
    body_hash[:included]
  end

  def find_included(type:)
    body_included.filter { _1[:type] == type.to_s }
  end

  def find_included_attributes(type:)
    body_included.filter { _1[:type] == type.to_s }.map { ActiveSupport::InheritableOptions.new(_1[:attributes]) }
  end

  class ObjectMock
    def initialize(record, included_records)
      @record = record
      @included_records = included_records
      @relationships = []

      define_singleton_method :id do
        @record[:id]
      end

      # attributes, relationships に type が使われない前提
      define_singleton_method :type do
        @record[:type]
      end

      @record[:attributes]&.each do |attribute, value|
        define_singleton_method attribute do
          value
        end
      end

      @record[:relationships]&.each do |relationship, data|
        # data[:data] が存在しない場合は controller で include に含まれていないということなので存在しないものとして扱う
        # ただし `lazy_load_data: true` がついている場合のみなので注意
        next unless data.key?(:data)

        data = data[:data]

        @relationships << relationship

        if data.is_a? Array
          children = data.map do |d|
            child = @included_records.find { _1[:type] == d[:type] && _1[:id] == d[:id] }
            raise "Not found #{d[:type]} #{d[:id]}" if child.blank?

            ObjectMock.new(child, @included_records)
          end

          define_singleton_method relationship do
            ObjectMockArray.new(children)
          end
        else
          child = if data.present?
            child = @included_records.find { _1[:type] == data[:type] && _1[:id] == data[:id] }
            raise "Not found #{data[:type]} #{data[:id]}" if child.blank?

            ObjectMock.new(child, @included_records)
          end

          define_singleton_method relationship do
            child
          end
        end
      end
    end

    def __attributes
      @record[:attributes] || {}
    end

    def __attribute_names
      @__attribute_names ||= @record[:attributes]&.keys&.map(&:to_sym) || []
    end

    def __relationships
      @__relationships ||= @relationships.map(&:to_sym)
    end

    def __descendants
      descendants = self.__relationships.map do |relationship|
        descendants = T.let(nil, T.untyped)

        case self.send(relationship)
        when Array
          next relationship if self.send(relationship).blank?

          # 一番情報が多いやつを返したい
          descendants = self.send(relationship).map(&:__descendants)[0]
        when ObjectMock
          descendants = self.send(relationship).__descendants
        end

        if descendants.present?
          {
            relationship => descendants,
          }
        else
          relationship
        end
      end.compact

      if descendants.filter { _1.is_a? Hash }.present?
        descendants.filter { _1.is_a? Symbol }.append(descendants.filter { _1.is_a? Hash }.reduce({}, :merge))
      else
        descendants
      end
    end

    def to_h
      __attributes.merge(__relationships.to_h { [_1, self.send(_1).to_h] })
    end

    def inspect
      {
        attributes: @record[:attributes],
        relationships: @relationships,
      }
    end
  end

  class ObjectMockArray < Array
    def to_h
      map(&:to_h)
    end
  end

  def deserialize
    if body_data.is_a? Array
      ObjectMockArray.new(body_data.map { ObjectMock.new(_1, body_included) })
    else
      ObjectMock.new(body_data, body_included)
    end
  end

  def deserialized
    @deserialized ||= deserialize
  end
end
