# typed: true

# ==============================================================================
# spec - helpers - komoju helper
# ==============================================================================
module KomojuHelper
  extend ActiveSupport::Concern

  class << self
    extend T::Sig

    def customer_params(id: nil, _body: nil)
      id ||= SecureRandom.alphanumeric(26)

      {
        id:,
        resource: 'customer',
        email: nil,
        source: {
          type: 'credit_card',
          brand: 'visa',
          last_four_digits: '0100',
          month: 9,
          year: 2025,
        },
        metadata: {
          user_id: SecureRandom.uuid,
        },
        created_at: '2023-05-07T05:42:13Z',
      }.deep_stringify_keys
    end

    def customer_session_params(customer_id: nil, _body: nil)
      id = SecureRandom.alphanumeric(26)
      customer_id ||= SecureRandom.alphanumeric(26)

      {
        id:,
        resource: 'session',
        mode: 'customer',
        amount: 0,
        currency: 'JPY',
        session_url: "https://komoju.com/sessions/#{id}",
        return_url: nil,
        default_locale: 'ja',
        payment_methods: [
          { type: 'credit_card', brands: ['visa', 'american_express', 'master', 'jcb', 'diners_club'], hashed_gateway: '15c6c4fc506a1b4e' },
          { type: 'paypay', offsite: true, additional_fields: [], hashed_gateway: 'c2420dec7af5cc5d' },
          { type: 'linepay', offsite: true, additional_fields: [], hashed_gateway: '89cb1d97db38194a' },
        ],
        created_at: '2023-08-22T13:05:50.000+09:00',
        cancelled_at: nil,
        completed_at: nil,
        status: 'pending',
        expired: false,
        metadata: {
          user_id: SecureRandom.uuid,
        },
        customer_id:,
      }.deep_stringify_keys
    end

    sig { params(params: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
    def payment_create_and_capture_response(params = {})
      response = {
        id: SecureRandom.alphanumeric(26).downcase,
        resource: 'payment',
        status: nil, # params
        amount: nil, # params
        tax: nil,    # params
        customer: nil, # params
        payment_deadline: nil, # params
        payment_details: {}, # params
        payment_method_fee: 0,
        total: nil, # params
        currency: 'JPY',
        description: nil,
        captured_at: nil, # params
        external_order_num: nil, # params
        metadata: {},
        created_at: nil, # params
        amount_refunded: 0,
        locale: 'ja',
        session: nil,
        customer_family_name: nil,
        customer_given_name: nil,
        mcc: nil,
        statement_descriptor: nil,
        refunds: [],
        refund_requests: [],
      }.deep_stringify_keys

      now_iso8601 = Time.zone.now.utc.iso8601

      response['amount'] = params['amount']
      response['tax']    = params['tax']
      response['created_at'] = now_iso8601

      if params['customer']
        # クレジットカード
        response['customer'] = params['customer']

        if params['capture']
          response['status'] = 'captured'
          response['captured_at'] = now_iso8601
        else
          response['status'] = 'authorized'
        end

        response['payment_details'] = {
          type: 'credit_card',
          email: 'test@example.com',
          brand: 'visa',
          last_four_digits: '0100',
          month: 8,
          year: 2099,
        }

        response['payment_deadline'] = now_iso8601
      else
        # それ以外
        response['status'] = 'authorized'
        response['payment_method_fee'] = 190

        response['payment_details'] = case params['payment_details']['type']
        when 'konbini'
          {
            type: 'konbini',
            email: 'aaa@aaa.com',
            store: 'seven-eleven',
            confirmation_code: nil,
            receipt: 13.times.map { rand(10) }.join,
            instructions_url: "https://komoju.com/ja/instructions/#{response['id']}",
          }
        when 'pay_easy'
          {
            type: 'pay_easy',
            email: 'aaa@aaa.com',
            bank_id: SecureRandom.alphanumeric(5).downcase,
            customer_id: SecureRandom.alphanumeric(10).downcase,
            confirmation_id: SecureRandom.alphanumeric(10).downcase,
            instructions_url: "https://komoju.com/ja/instructions/#{response['id']}",
            payment_url: 'https://example.com',
            cvs_code: nil,
          }
        end

        response['payment_deadline'] = if params.dig('payment_details', 'expiry_days')
          (Time.zone.today + params.dig('payment_details', 'expiry_days').days).end_of_day.utc.iso8601
        else
          3.days.from_now.utc.iso8601
        end
      end

      response['total'] = response['amount'] + response['tax'] + response['payment_method_fee']

      response.deep_stringify_keys
    end

    sig { params(override_data: T::Array[T::Hash[T.any(Symbol, String), T.untyped]]).returns(T::Hash[String, T.untyped]) }
    def payment_list_response(override_data = [])
      data = override_data.presence || [
        {
          id: 'bk3lh5xnsj25e22mn7zo2mgqh',
          resource: 'payment',
          status: 'pending',
          amount: 100,
          tax: 10,
          customer: nil,
          payment_deadline: '2023-08-10T14:59:59Z',
          payment_details: { type: 'credit_card', email: nil, brand: 'visa', last_four_digits: '1042', month: 11, year: 2099 },
          payment_method_fee: 0,
          total: 110,
          currency: 'JPY',
          description: nil,
          captured_at: nil,
          external_order_num: '𝕏',
          metadata: {},
          created_at: '2023-08-08T09:56:16Z',
          amount_refunded: 0,
          locale: 'ja',
          session: nil,
          customer_family_name: nil,
          customer_given_name: nil,
          mcc: nil,
          statement_descriptor: nil,
          refunds: [],
          refund_requests: [],
        },
      ]

      {
        resource: 'list',
        total: 1,
        page: 1,
        per_page: 10,
        last_page: 1,
        data:,
      }.deep_stringify_keys
    end

    sig { returns(T::Hash[String, T::Array[T.untyped]]) }
    def payment_show_response_data
      @payment_show_response_data ||= {}
    end

    # show で返ってきて欲しい response を設定する
    # add する度に配列に response が追加され、show が呼ばれる度に配列の先頭を取り出して返す
    # なので show の度に異なる response を返したい場合はその順番通りに add_payment_show_response すればよい
    sig { params(komoju_id: String, response: T::Hash[String, T.untyped]).void }
    def add_payment_show_response(komoju_id, response)
      data = payment_show_response_data[komoju_id] ||= []
      data << response
    end

    # --------------------------------------------------------------------------
    # error response
    # --------------------------------------------------------------------------
    sig { returns(Excon::Error::NotFound) }
    def not_found_exception
      Excon::Error::NotFound.new(
        'Expected([200, 201, 202, 204, 206, 304]) <=> Actual(404 Not Found)',
        nil, # request
        Excon::Response.new({
          body: '{"error":{"code":"not_found","message":"The requested resource could not be found.","param":null,"details":{}}}',
          cookies: [],
          host: 'komoju.com',
          scheme: 'https',
          method: :post,
          headers: {}, # 省略
          path: '/api/v1/payments',
          query: nil,
          port: 443,
          omit_default_port: false,
          status: 404,
          status_line: "HTTP/1.1 404 Not Found\r\n",
          reason_phrase: 'Not Found',
          remote_ip: '127.0.0.1',
          local_port: 37_266,
          local_address: '127.0.0.1',
        }),
      )
    end

    sig { params(body: T.nilable(String)).returns(Excon::Error::UnprocessableEntity) }
    def unprocessable_entity_exception(body: nil)
      Excon::Error::UnprocessableEntity.new(
        'Expected([200, 201, 202, 204, 206, 304]) <=> Actual(422 Unprocessable Entity)',
        nil, # request
        Excon::Response.new({
          body: body || '{"error":{"code":"not_refundable","message":"The payment you requested is not refundable.","param":null,"details":{}}}', # body は適当
          cookies: [],
          host: 'komoju.com',
          scheme: 'https',
          method: :post,
          headers: {}, # 省略
          path: '/api/v1/payments',
          query: nil,
          port: 443,
          omit_default_port: false,
          status: 422,
          status_line: "HTTP/1.1 422 Unprocessable Entity\r\n",
          reason_phrase: 'Unprocessable Entity',
          remote_ip: '127.0.0.1',
          local_port: 37_266,
          local_address: '127.0.0.1',
        }),
      )
    end

    sig { params(code: Symbol).returns(Excon::Error::BadGateway) }
    def bad_gateway_exception(code:)
      body = case code
      when :bad_verification_value
        '{"error":{"code":"bad_verification_value","message":"The security code you have entered is incorrect.","param":null,"details":{},"details":null}}'
      when :exceeds_limit
        '{"error":{"code":"exceeds_limit","message":"Exceeds card limit","param":null,"details":{},"details":null}}'
      when :card_expired
        '{"error":{"code":"card_expired","message":"Your card has expired.","param":null,"details":{},"details":null}}'
      when :card_declined
        '{"error":{"code":"card_declined","message":"Your card has been declined.","param":null,"details":{},"decline_details":null}}'
      else
        raise 'invalid code'
      end

      Excon::Error::BadGateway.new(
        "Expected([200, 201, 202, 204, 206, 304]) <=> Actual(502 Bad Gateway)\n",
        nil, # request
        Excon::Response.new({
          body:,
          cookies: [],
          host: 'komoju.com',
          scheme: 'https',
          method: :post,
          headers: {}, # 省略
          path: '/api/v1/payments',
          query: nil,
          port: 443,
          omit_default_port: false,
          status: 502,
          status_line: "HTTP/1.1 502 Bad Gateway\r\n",
          reason_phrase: 'Bad Gateway',
          remote_ip: '127.0.0.1',
          local_port: 37_266,
          local_address: '127.0.0.1',
        }),
      )
    end

    sig { returns(Excon::Error::InternalServerError) }
    def internal_server_error_exception
      Excon::Error::InternalServerError.new('Internal Server Error')
    end

    sig { returns(Excon::Error::GatewayTimeout) }
    def gateway_timeout_exception
      Excon::Error::GatewayTimeout.new('Gateway Timeout')
    end
  end

  included do
    T.bind(self, T.untyped)

    let(:komoju_payments_mock) { Komoju::Payments.new(client: '') }

    before do
      allow_any_instance_of(Tenant).to receive(:komoju_api_key).and_return('this_is_komoju_api_key')

      # Komoju::Customers
      allow_any_instance_of(Komoju::Customers).to receive(:show).and_wrap_original do |_original_method, *args|
        KomojuHelper.customer_params(id: args[0])
      end
      allow_any_instance_of(Komoju::Customers).to receive(:create).and_wrap_original do |_original_method, *args|
        KomojuHelper.customer_params(_body: args[0])
      end
      allow_any_instance_of(Komoju::Customers).to receive(:update).and_wrap_original do |_original_method, *args|
        KomojuHelper.customer_params(id: args[0], _body: args[1])
      end
      allow_any_instance_of(Komoju::Customers).to receive(:destroy).and_wrap_original do |_original_method, *args|
        KomojuHelper.customer_params(id: args[0])
      end

      # Komoju::Sessions
      allow_any_instance_of(KomojuRecord::Client::Sessions).to receive(:create).and_wrap_original do |_original_method, params|
        KomojuHelper.customer_session_params(customer_id: params.serialize['customer_id'])
      end

      # Komoju::Payments
      allow(Komoju::Payments).to receive(:new).and_return(komoju_payments_mock)
      allow(komoju_payments_mock).to receive(:show).and_wrap_original do |_original_method, komoju_id|
        komoju_payment = KomojuRecord::Payment.find_by(komoju_id:)

        if komoju_payment.blank?
          KomojuHelper.not_found_exception
        else
          data = KomojuHelper.payment_show_response_data[komoju_id]&.shift || {}
          komoju_payment.komoju_data.merge(data)
        end
      end
      allow(komoju_payments_mock).to receive(:create).and_wrap_original do |_original_method, params|
        # 0円の決済はエラーが発生するのでテストでもエラーを発生させる
        if params['amount'] <= 0
          raise KomojuHelper.unprocessable_entity_exception(
            body: ({ error: { code: 'invalid_parameter', message: 'Amount must be greater than 0', param: 'amount', details: {} } }).to_json,
          )
        end

        # params['customer'] を以下のコードから始まる文字列にするとそれぞれの理由での決済エラーをシミュレーションできる
        # unique constraint があるため、エラーコードだけを指定すると重複エラーが出るので `bad_verification_value_random` のようにランダムな文字列を suffix として付与する
        # 使用例としては an_user.komoju_record_customers.first.update!(customer_id: 'card_declined_0001') のように、komoju_record_customers の customer_id を変更する
        case params['customer']&.to_s
        when /\Abad_verification_value_.*\z/
          raise KomojuHelper.bad_gateway_exception(code: :bad_verification_value)
        when /\Aexceeds_limit_.*\z/
          raise KomojuHelper.bad_gateway_exception(code: :exceeds_limit)
        when /\Acard_expired_.*\z/
          raise KomojuHelper.bad_gateway_exception(code: :card_expired)
        when /\Acard_declined_.*\z/
          raise KomojuHelper.bad_gateway_exception(code: :card_declined)
        when /\Afraudulent.*\z/
          raise KomojuHelper.unprocessable_entity_exception(
            body: ({ error: { code: 'fraudulent', message: 'The payment could not be completed.', param: nil, details: {} } }).to_json,
          )
        # 以下は KOMOJU が意図しないエラーを返してきた場合のシミュレーション
        when /\Ainternal_server_error_.*\z/
          raise KomojuHelper.internal_server_error_exception
        when /\Agateway_timeout_.*\z/
          raise KomojuHelper.gateway_timeout_exception
        end

        # コンビニ、pay-easy の場合は user.email を特定の値にすることでエラーをシミュレーションできる
        case params.dig('payment_details', 'email')
        when /\Aunprocessable_entity_.*@.+\z/
          raise KomojuHelper.unprocessable_entity_exception
        when /\Ainternal_server_error_.*@.+\z/
          raise KomojuHelper.internal_server_error_exception
        end

        KomojuHelper.payment_create_and_capture_response(params)
      end
      allow(komoju_payments_mock).to receive(:capture).and_wrap_original do |_original_method, komoju_id|
        komoju_payment = KomojuRecord::Payment.find_by(komoju_id:)

        if komoju_payment
          KomojuHelper.payment_create_and_capture_response(komoju_payment.komoju_data.merge('capture' => true))
        else
          KomojuHelper.payment_create_and_capture_response # TODO: エラー出るのでちゃんと実装する
        end
      end
      allow(komoju_payments_mock).to receive(:list).and_wrap_original do |_original_method, _params|
        KomojuHelper.payment_list_response
      end
    end
  end
end
