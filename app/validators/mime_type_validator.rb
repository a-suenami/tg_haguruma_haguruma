# typed: true
# frozen_string_literal: true

class MimeTypeValidator
  extend T::Sig

  class InvalidMimeTypeError < StandardError
    extend T::Sig

    sig { returns(String) }
    attr_reader :message

    sig { params(allowed_extensions: T::Array[String]).void }
    def initialize(allowed_extensions)
      @message = T.let("#{allowed_extensions.join(', ')}のみアップロードできます", String)
      super(@message)
    end
  end

  ALLOWED_MIME_TYPES = T.let({
    image: %w[image/jpeg image/png image/gif image/webp image/svg+xml],
    video: %w[video/mp4 video/webm video/quicktime],
    audio: %w[audio/mpeg audio/wav audio/ogg audio/webm],
    document: %w[application/pdf],
  }.freeze, T::Hash[Symbol, T::Array[String]])

  MIME_TYPE_TO_EXTENSION = T.let({
    'image/jpeg' => 'JPEG',
    'image/png' => 'PNG',
    'image/gif' => 'GIF',
    'image/webp' => 'WebP',
    'image/svg+xml' => 'SVG',
    'video/mp4' => 'MP4',
    'video/webm' => 'WebM',
    'video/quicktime' => 'MOV',
    'audio/mpeg' => 'MP3',
    'audio/wav' => 'WAV',
    'audio/ogg' => 'OGG',
    'audio/webm' => 'WebM Audio',
    'application/pdf' => 'PDF',
  }.freeze, T::Hash[String, String])

  sig { returns(T::Array[String]) }
  def self.all_allowed_mime_types
    ALLOWED_MIME_TYPES.values.flatten
  end

  sig { returns(T::Array[String]) }
  def self.allowed_extensions
    all_allowed_mime_types.map { |mime| MIME_TYPE_TO_EXTENSION[mime] }.compact.uniq
  end

  sig { params(mime_type: String).returns(T::Boolean) }
  def self.allowed?(mime_type)
    all_allowed_mime_types.include?(mime_type)
  end

  sig { params(file: ActionDispatch::Http::UploadedFile).returns(T::Boolean) }
  def self.valid?(file)
    declared_type = file.content_type
    return false unless allowed?(declared_type.to_s)

    # マジックナンバーによる実際の MIME タイプ検証
    detected_type = detect_mime_type(file)
    return false unless detected_type

    allowed?(detected_type) && mime_types_compatible?(declared_type.to_s, detected_type)
  end

  sig { params(file: ActionDispatch::Http::UploadedFile).void }
  def self.validate!(file)
    raise InvalidMimeTypeError.new(allowed_extensions) unless valid?(file)
  end

  sig { params(file: ActionDispatch::Http::UploadedFile).returns(T.nilable(String)) }
  def self.detect_mime_type(file)
    file.rewind
    content = file.read(4096) # 最初の4KBを読み取り
    file.rewind

    return nil if content.nil?

    Marcel::MimeType.for(StringIO.new(content), name: file.original_filename)
  end

  sig { params(declared: String, detected: String).returns(T::Boolean) }
  def self.mime_types_compatible?(declared, detected)
    # 完全一致
    return true if declared == detected

    # SVG は text/html として検出されることがあるため特別処理
    return true if declared == 'image/svg+xml' && detected == 'text/html'
    return true if declared == 'image/svg+xml' && detected == 'application/xml'
    return true if declared == 'image/svg+xml' && detected == 'text/xml'

    # audio/webm と video/webm は同じコンテナフォーマット
    return true if declared == 'audio/webm' && detected == 'video/webm'

    false
  end

  private_class_method :detect_mime_type, :mime_types_compatible?
end
