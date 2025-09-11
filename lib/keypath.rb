# typed: strict
# frozen_string_literal: true

module Keypath
  extend T::Sig

  sig { params(obj: T.untyped, keypath: String).returns(T.untyped) }
  def self.dig(obj, keypath)
    keys = keypath.split('.').map do |k|
      # 数字の場合は数値インデックスに変換
      k.match?(/\A\d+\z/) ? k.to_i : k
    end
    obj.dig(*keys)
  end

  sig { params(obj: T.untyped, keypath: String, value: T.untyped).returns(T.untyped) }
  def self.set(obj, keypath, value)
    keys = keypath.split('.')
    last_key = T.must(keys.pop)
    last_key = last_key.to_i if last_key =~ /\A\d+\z/

    # Navigate to the parent object
    current = obj
    keys.each_with_index do |key, index|
      # 数値のキーは整数として処理（配列へのアクセス）
      is_index = key =~ /\A\d+\z/
      key = key.to_i if is_index

      if current[key].nil?
        # 次のキーが数字の場合は配列を、そうでない場合はハッシュを作成
        next_key = keys[index + 1] || last_key
        next_is_index = next_key.is_a?(Integer) || (next_key.is_a?(String) && next_key =~ /\A\d+\z/)
        current[key] = next_is_index ? [] : {}
      end
      current = current[key]
    end

    # Set the value in the parent object
    current[last_key] = value

    obj # 変更したオブジェクトを返す
  end
end
