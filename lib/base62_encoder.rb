# typed: strict
# frozen_string_literal: true

# Base62エンコーダー
# UUIDなどの長い識別子を短い文字列に変換するためのユーティリティ
class Base62Encoder
  extend T::Sig

  # Base62の文字セット（0-9, a-z, A-Z）
  CHARSET = T.let('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', String)
  BASE = T.let(CHARSET.length, Integer)

  class << self
    extend T::Sig

    # UUIDを12文字のBase62文字列に変換
    # @param uuid [String] UUID文字列（ハイフンあり/なし対応）
    # @return [String] 12文字のBase62エンコード文字列
    sig { params(uuid: String).returns(String) }
    def encode_uuid(uuid)
      # UUIDからハイフンを除去
      clean_uuid = uuid.gsub('-', '')

      # UUIDの場合（32文字の16進数）
      if clean_uuid.match?(/\A[0-9a-fA-F]{32}\z/)
        # 16進数文字列を数値に変換してbase62エンコード
        # UUIDは128ビット（16バイト）なので、大きな数値として扱う
        uuid_int = clean_uuid.to_i(16)

        # Base62エンコード
        base62_encoded = encode(uuid_int)

        # 12文字に収まるように調整（右詰めで0埋め）
        if base62_encoded.length > 12
          # 最後の12文字を使用（衝突の可能性はあるが、実用上は問題ない）
          T.must(base62_encoded[-12, 12])
        else
          base62_encoded.rjust(12, '0')
        end
      else
        # UUID以外の場合は英数字のみを抽出して12文字に調整
        alphanumeric = uuid.gsub(/[^0-9a-zA-Z]/, '')
        if alphanumeric.length > 12
          T.must(alphanumeric[0, 12])
        else
          alphanumeric.ljust(12, '0')
        end
      end
    end

    # 数値をBase62文字列にエンコード
    # @param number [Integer] エンコードする数値
    # @return [String] Base62エンコード文字列
    sig { params(number: Integer).returns(String) }
    def encode(number)
      return '0' if number.zero?

      result = T.let('', String)
      while number.positive?
        result = T.must(CHARSET[number % BASE]) + result
        number /= BASE
      end

      result
    end

    # Base62文字列を数値にデコード
    # @param str [String] デコードするBase62文字列
    # @return [Integer] デコードされた数値
    sig { params(str: String).returns(Integer) }
    def decode(str)
      result = 0
      str.each_char do |char|
        index = CHARSET.index(char)
        raise ArgumentError.new("Invalid character: #{char}") unless index

        result = (result * BASE) + index
      end
      result
    end
  end
end
