# typed: strict

require 'json'

module Eventbridge
  class MessageParam < T::Struct
    extend T::Sig

    const :version, String
    const :id, String
    const :detail_type, String
    const :source, String
    const :account, String
    const :time, String
    const :region, String
    const :resources, T::Array[T.untyped]
    const :detail, T.nilable(T::Hash[T.untyped, T.untyped])

    sig { params(data: T::Hash[String, T.untyped]).returns(Eventbridge::MessageParam) }
    def self.build_from_hash(data)
      detail_data = data['detail']
      detail_hash = detail_data.is_a?(Hash) ? detail_data.deep_stringify_keys : nil

      Eventbridge::MessageParam.new(
        version: data['version'],
        id: data['id'],
        detail_type: data['detail-type'],
        source: data['source'],
        account: data['account'],
        time: data['time'],
        region: data['region'],
        resources: data['resources'],
        detail: detail_hash,
      )
    end
  end

  class UserMailEventParams < T::Struct
    extend T::Sig

    class DetailParams < T::Struct
      extend T::Sig

      prop :tenant_id, String
      prop :user_id, String
      prop :user_uid, String
      prop :code, String
      prop :body, String
    end

    const :detail_type, String, default: 'HAGURUMA User Mail Event'
    const :detail, UserMailEventParams::DetailParams

    sig { returns(T::Hash[String, T.untyped]) }
    def serialize
      hash = super
      hash['detail'] = detail.serialize.to_json

      hash
    end
  end

  class Client
    extend T::Sig

    sig { params(params: UserMailEventParams, source: T.nilable(String), event_bus_name: T.nilable(String)).void }
    def put_event(params, source: nil, event_bus_name: nil)
      source ||= Settings.aws.eventbridge.default_source
      event_bus_name ||= Settings.aws.eventbridge.default_bus_name

      eventbridge_client.put_events({
        entries: [
          {
            source:,
            event_bus_name:,
            **params.serialize,
          }.symbolize_keys,
        ],
      })
    end

    private

    sig { returns(Aws::EventBridge::Client) }
    def eventbridge_client
      @eventbridge_client ||= T.let(
        ::Aws::EventBridge::Client.new(
          region: Settings.aws.eventbridge.region,
          credentials:,
        ),
        T.nilable(Aws::EventBridge::Client),
      )
    end

    sig { returns(T.any(Aws::Credentials, Aws::ECSCredentials)) }
    def credentials
      if Settings.aws.eventbridge.access_key_id
        Aws::Credentials.new(Settings.aws.eventbridge.access_key_id, Settings.aws.eventbridge.secret_access_key)
      else
        Aws::ECSCredentials.new
      end
    end
  end
end
