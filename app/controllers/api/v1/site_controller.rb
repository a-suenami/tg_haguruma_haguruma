# typed: strict
# frozen_string_literal: true

module Api
  module V1
    class SiteController < ApplicationController
      extend T::Sig

      sig { void }
      def show
        render json: {
          data: {
            custom_variables: serialize_custom_variables,
          },
        }
      end

      private

      sig { returns(T::Array[T::Hash[Symbol, T.untyped]]) }
      def serialize_custom_variables
        custom_variables.map do |var|
          {
            unique_name: var.unique_name,
            variable_type: var.variable_type,
            value: serialize_value(var),
          }
        end
      end

      sig { returns(SiteCustomVariable::Collection) }
      def custom_variables
        @custom_variables ||= T.let(
          SiteCustomVariable::Collection.new(SiteCustomVariable.active.to_a),
          T.nilable(SiteCustomVariable::Collection),
        )
      end

      sig { params(var: SiteCustomVariable).returns(T.nilable(T.any(T::Boolean, String))) }
      def serialize_value(var)
        case var.variable_type
        when 'boolean'
          var.boolean_value
        when 'datetime'
          var.datetime_value&.iso8601
        when 'text'
          var.text_value
        end
      end
    end
  end
end
