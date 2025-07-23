# typed: true

# ==============================================================================
# spec - helpers - gmo payment helper
# ==============================================================================
module GmoPaymentHelper
  extend ActiveSupport::Concern

  module Members
    extend ActiveSupport::Concern

    class << self
      extend T::Sig

      sig { params(id: String).returns(T::Hash[String, T.untyped]) }
      def show_response(id:)
        # id を以下のコードから始まる文字列にするとそれぞれの理由でのエラーをシミュレーションできる
        case id
        when /\Anot_exist_member.*\z/
          raise ::GMO::Payment::APIError.new({ ErrCode: 'E01', ErrInfo: 'E01390002', ErrMessage: 'Site ID and Member ID do not exist' }.stringify_keys)
        else
          {
            MemberID: id,
            MemberName: 'TEST MEMBER',
            DeleteFlag: '0',
          }.stringify_keys
        end
      end
    end
  end

  module Cards
    extend ActiveSupport::Concern

    class << self
      extend T::Sig

      sig { params(id: String).returns(T::Hash[String, T.untyped]) }
      def show_response(id:)
        # id を以下のコードから始まる文字列にするとそれぞれの理由でのエラーをシミュレーションできる
        case id
        when /\Aexpired_card.*\z/
          {
            CardSeq: '0',
            DefaultFlag: '1',
            CardName: '',
            CardNo: '************1111',
            Expire: '2001',
            HolderName: 'TEST MEMBER',
            DeleteFlag: '0',
          }.stringify_keys
        else
          {
            CardSeq: '0',
            DefaultFlag: '1',
            CardName: '',
            CardNo: '************1111',
            Expire: '3001',
            HolderName: 'TEST MEMBER',
            DeleteFlag: '0',
          }.stringify_keys
        end
      end
    end
  end

  module Payments
    extend ActiveSupport::Concern

    class << self
      extend T::Sig

      sig { params(id: String).returns(T::Hash[String, T.untyped]) }
      def show_response(id:)
        # id を以下のコードから始まる文字列にするとそれぞれの理由でのエラーをシミュレーションできる
        case id
        when /\Anot_exist_payment.*\z/
          raise ::GMO::Payment::APIError.new({ ErrCode: 'E01', ErrInfo: 'E01390002', ErrMessage: 'Site ID and Member ID do not exist' }.stringify_keys)
        else
          response = @payment_show_response_data[id] || {}

          if response.blank?
            raise ::GMO::Payment::APIError.new({ ErrCode: 'E01', ErrInfo: 'E01110002', ErrMessage: 'Access ID and Password are invalid' }.stringify_keys)
          end

          response.stringify_keys
        end
      end

      sig { params(params: GmoPaymentRecord::Client::Payments::EntryParams).returns(T::Hash[String, T.untyped]) }
      def entry_response(params)
        add_payment_show_response(params.order_id, base_show_response.merge(OrderID: params.order_id, Status: 'UNPROCESSED'))

        {
          AccessID: SecureRandom.hex(16),
          AccessPass: SecureRandom.hex(16),
        }.stringify_keys
      end

      sig { params(params: GmoPaymentRecord::Client::Payments::ExecuteParams).returns(T::Hash[String, T.untyped]) }
      def execute_response(params)
        # member_id を以下のコードから始まる文字列にするとそれぞれの理由でのエラーをシミュレーションできる
        case params.member_id
        when /\Anot_exist_card.*\z/
          raise ::GMO::Payment::APIError.new({ ErrCode: 'E01', ErrInfo: 'E01240002', ErrMessage: 'Card specified does not exist' }.stringify_keys)
        when /\Aexceeds_limit.*\z/
          raise ::GMO::Payment::APIError.new({ ErrCode: 'G03', ErrInfo: '42G030000', ErrMessage: 'Card limit has been exceeded' }.stringify_keys)
        when /\Acard_expired.*\z/
          raise ::GMO::Payment::APIError.new({ ErrCode: 'G83', ErrInfo: '42G830000', ErrMessage: 'Expiration date is incorrect' }.stringify_keys)
        when /\Acard_declined.*\z/
          raise ::GMO::Payment::APIError.new({ ErrCode: 'G99', ErrInfo: '42G990000', ErrMessage: 'Card is not valid for transactions' }.stringify_keys)
        else
          tran_id = SecureRandom.hex(14)
          approve = '0214112'

          add_payment_show_response(
            params.order_id,
            @payment_show_response_data[params.order_id].merge!(
              OrderID: params.order_id,
              Status: 'CAPTURE',
              Approve: approve,
              TranID: tran_id,
            ),
          )

          {
            ACS: 0,
            OrderID: params.order_id,
            Forward: SecureRandom.alphanumeric(7).downcase,
            Method: 1,
            PayTimes: '',
            Approve: approve,
            TranID: tran_id,
            TranDate: '20241016151403',
            CheckString: 'ad4140fda664269b965a4a33bb40b94',
          }.stringify_keys
        end
      end

      private

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def base_show_response
        {
          ProcessDate: '20241016151403',
          JobCd: 'CAPTURE',
          AccessID: '4e259dd840310ab2c915d51336855ce3',
          AccessPass: '6ddeadc27c4bbfd97e806996d1e88525',
          ItemCode: '0000990',
          Amount: '100',
          Tax: '0',
          SiteID: 'tsite00011026',
          MemberID: 'triple-test-member-001',
          CardNo: '************1111',
          Expire: '3001',
          Method: '1',
          PayTimes: '',
          Forward: '2a99662',
          TranID: '',
          Approve: '',
          ClientField1: '', # rubocop:disable Naming/VariableNumber
          ClientField2: '', # rubocop:disable Naming/VariableNumber
          ClientField3: '', # rubocop:disable Naming/VariableNumber
        }
      end

      sig { returns(T::Hash[String, T::Hash[Symbol, T.untyped]]) }
      def payment_show_response_data
        @payment_show_response_data ||= {}
      end

      sig { params(order_id: String, response: T::Hash[Symbol, T.untyped]).void }
      def add_payment_show_response(order_id, response)
        payment_show_response_data[order_id] ||= response
      end
    end
  end

  class << self
    extend T::Sig
  end

  included do
    T.bind(self, T.untyped)

    before do
      allow_any_instance_of(Tenant).to receive(:gmo_payment_api_host).and_return('api.example.com')
      allow_any_instance_of(Tenant).to receive(:gmo_payment_site_id).and_return('this_is_gmo_payment_site_id')
      allow_any_instance_of(Tenant).to receive(:gmo_payment_site_pass).and_return('this_is_gmo_payment_site_pass')
      allow_any_instance_of(Tenant).to receive(:gmo_payment_shop_id).and_return('this_is_gmo_payment_shop_id')
      allow_any_instance_of(Tenant).to receive(:gmo_payment_shop_pass).and_return('this_is_gmo_payment_shop_pass')

      # GmoPaymentRecord::Member
      allow_any_instance_of(GmoPaymentRecord::Client::Members).to receive(:show).and_wrap_original do |_original_method, *args|
        GmoPaymentRecord::Client.handle_exception do
          GmoPaymentHelper::Members.show_response(id: args[0])
        end
      end

      # GmoPaymentRecord::Member
      allow_any_instance_of(GmoPaymentRecord::Client::Cards).to receive(:show).and_wrap_original do |_original_method, *args|
        GmoPaymentRecord::Client.handle_exception do
          GmoPaymentHelper::Cards.show_response(id: args[0])
        end
      end

      # GmoPaymentRecord::Payment
      allow_any_instance_of(GmoPaymentRecord::Client::Payments).to receive(:entry).and_wrap_original do |_original_method, *args|
        GmoPaymentRecord::Client.handle_exception do
          GmoPaymentHelper::Payments.entry_response(args[0])
        end
      end
      allow_any_instance_of(GmoPaymentRecord::Client::Payments).to receive(:execute).and_wrap_original do |_original_method, *args|
        GmoPaymentRecord::Client.handle_exception do
          GmoPaymentHelper::Payments.execute_response(args[0])
        end
      end
      allow_any_instance_of(GmoPaymentRecord::Client::Payments).to receive(:show).and_wrap_original do |_original_method, *args|
        GmoPaymentRecord::Client.handle_exception do
          GmoPaymentHelper::Payments.show_response(id: args[0])
        end
      end
    end
  end
end
