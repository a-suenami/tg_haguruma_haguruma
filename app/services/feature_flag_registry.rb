# typed: true
# frozen_string_literal: true

class FeatureFlagRegistry
  extend T::Sig

  FEATURES = T.let({
    admin_category: {
      name: '管理画面のカテゴリ機能',
      description: '管理画面でカテゴリを管理する機能',
      scope: :tenant,
    },
    admin_new_ui: {
      name: '管理画面の新UI',
      description: '管理画面の新しいUIを有効にする',
      scope: :tenant,
    },
    cloudflare_stream_sync: {
      name: 'Cloudflare Stream 動画同期',
      description: '動画アップロード時にCloudflare Streamへ非同期で同期する',
      scope: :global,
    },
  }.freeze, T::Hash[Symbol, T::Hash[Symbol, T.untyped]],)

  class << self
    extend T::Sig

    sig { returns(T::Hash[Symbol, T::Hash[Symbol, T.untyped]]) }
    def all
      FEATURES
    end

    sig { returns(T::Hash[Symbol, T::Hash[Symbol, T.untyped]]) }
    def tenant_scoped
      FEATURES.select { |_, v| v[:scope] == :tenant }
    end

    sig { returns(T::Hash[Symbol, T::Hash[Symbol, T.untyped]]) }
    def global_scoped
      FEATURES.select { |_, v| v[:scope] == :global }
    end

    sig { params(name: T.any(Symbol, String)).returns(T::Boolean) }
    def feature_exists?(name)
      FEATURES.key?(name.to_sym)
    end

    sig { params(name: T.any(Symbol, String)).returns(T.nilable(T::Hash[Symbol, T.untyped])) }
    def get(name)
      FEATURES[name.to_sym]
    end

    sig { void }
    def seed!
      FEATURES.each_key do |feature_name|
        Flipper.add(feature_name) unless Flipper.exist?(feature_name)
      end
    end
  end
end
