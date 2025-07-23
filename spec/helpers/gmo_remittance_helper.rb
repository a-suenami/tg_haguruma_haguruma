# typed: true

# ==============================================================================
# spec - helpers - GmoRemittance helper
# ==============================================================================
module GmoRemittanceHelper
  extend ActiveSupport::Concern

  class << self
    extend T::Sig

    sig { params(receipt_info_registered: T::Boolean, deposit_date: T::Boolean, remittance_failed: T::Boolean).returns(T.nilable(T::Hash[String, T.untyped])) }
    def show_response(receipt_info_registered: true, deposit_date: true, remittance_failed: false)
      if receipt_info_registered
        {
          Deposit_ID: '2024022802',
          Remittance_Method: '1',
          Amount: '0',
          Free: '',
          sevenatm: {
            Customer_Number: '511000111',
            Conf_Number: '406639',
            Sevenatm_Result: remittance_failed ? '3' : '1',
            Payable_Amount: '100',
            Mail_Address: 'triple@twogate.com',
            Fee: '300',
            Deposit_Date: deposit_date ? '2024-02-28' : '',
            Partner_Code: '0181',
          },
        }.deep_stringify_keys
      end
    end

    def create_response
      {
        Redirect_Url: "https://test-remittance.gmopg.jp/mail/mail-deposit?token=#{SecureRandom.alphanumeric(32)}",
        Deposit_ID: '2024030601-05',
        Method: '1',
      }.deep_stringify_keys
    end
  end

  included do
    T.bind(self, T.untyped)

    before do
      allow_any_instance_of(Tenant).to receive(:gmo_remittance_shop_id).and_return('this_is_gmo_remittance_shop_id')
      allow_any_instance_of(Tenant).to receive(:gmo_remittance_shop_pass).and_return('this_is_gmo_remittance_shop_pass')

      # Remittances
      allow_any_instance_of(GmoRemittanceRecord::Remittance).to receive(:request_show).and_wrap_original do |_original_method, *_args|
        GmoRemittanceHelper.show_response
      end
      allow_any_instance_of(GmoRemittanceRecord::Remittance).to receive(:request_create).and_wrap_original do |_original_method, *_args|
        GmoRemittanceHelper.create_response
      end
      allow_any_instance_of(GmoRemittanceRecord::Remittance).to receive(:request_destroy).and_return(nil)
    end
  end
end
