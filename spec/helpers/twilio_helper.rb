# typed: true

# ==============================================================================
# spec - helpers - twilio helper
# ==============================================================================
module TwilioHelper
  extend ActiveSupport::Concern

  module Verifications
    extend ActiveSupport::Concern

    class << self
      extend T::Sig

      sig {
        params(
          params: TwilioRecord::Client::Request::Verification::RequestParams,
        ).returns(
          Mangrove::Result[
            TwilioRecord::Client::Response::Verification,
            T.untyped,
          ],
        )
      }
      def create_response(params)
        Mangrove::Result::Ok.new(
          TwilioRecord::Client::Response::Verification.new(
            sid: "VA#{SecureRandom.alphanumeric(32)}",
            service_sid: Settings.twilio.verify.service_sid,
            account_sid: Settings.twilio.account_sid,
            to: params.to,
            channel: params.channel.serialize,
            status: 'pending',
            valid: false,
            date_created: Time.zone.now.to_s,
            date_updated: Time.zone.now.to_s,
            lookup: { 'carrier' => nil },
            amount: nil,
            payee: nil,
            send_code_attempts: [
              TwilioRecord::Client::Response::SendCodeAttempt.new(
                time: Time.zone.now.to_s,
                channel: params.channel.serialize,
                attempt_sid: 'VLaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
              ),
            ],
            sna: nil,
            url: 'https://verify.twilio.com/v2/Services/VAaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/Verifications/VEaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          ),
        )
      end
    end
  end

  included do
    T.bind(self, T.untyped)

    before do
      # Verifications
      allow_any_instance_of(TwilioRecord::Client::Verifications).to receive(:create).and_wrap_original do |_original_method, *args|
        TwilioHelper::Verifications.create_response(args[0])
      end
    end
  end
end
