# typed: true

# ==============================================================================
# spec - helpers - sms link helper
# ==============================================================================
module SMSLinkHelper
  extend ActiveSupport::Concern

  module Verifications
    extend ActiveSupport::Concern

    class << self
      extend T::Sig

      sig {
        params(
          params: SMSLinkRecord::Client::Request::Verification::RequestParams,
        ).returns(
          Mangrove::Result[
            SMSLinkRecord::Client::Response::Verification,
            T.untyped,
          ],
        )
      }
      def create_response(params)
        Mangrove::Result::Ok.new(
          SMSLinkRecord::Client::Response::Verification.new(
            verification_code_id: SecureRandom.random_number(9999).to_s,
            accepted_at: Time.zone.now.to_s,
            phone_number: params.phone_number,
            verification_code: params.verification_code,
            delivery_type: SMSLinkRecord::Client::Response::DeliveryType.deserialize(params.delivery_type.serialize),
          ),
        )
      end
    end
  end

  included do
    T.bind(self, T.untyped)

    before do
      # Verifications
      allow_any_instance_of(SMSLinkRecord::Client::Verifications).to receive(:create).and_wrap_original do |_original_method, *args|
        SMSLinkHelper::Verifications.create_response(args[0])
      end
    end
  end
end
