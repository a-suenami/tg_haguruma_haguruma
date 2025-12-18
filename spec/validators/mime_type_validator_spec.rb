# typed: false
# frozen_string_literal: true

describe MimeTypeValidator do
  describe '.allowed?' do
    context '許可されたMIMEタイプの場合' do
      it 'image/jpeg を許可する' do
        expect(described_class.allowed?('image/jpeg')).to be true
      end

      it 'image/png を許可する' do
        expect(described_class.allowed?('image/png')).to be true
      end

      it 'image/gif を許可する' do
        expect(described_class.allowed?('image/gif')).to be true
      end

      it 'image/webp を許可する' do
        expect(described_class.allowed?('image/webp')).to be true
      end

      it 'image/svg+xml を許可する' do
        expect(described_class.allowed?('image/svg+xml')).to be true
      end

      it 'video/mp4 を許可する' do
        expect(described_class.allowed?('video/mp4')).to be true
      end

      it 'video/webm を許可する' do
        expect(described_class.allowed?('video/webm')).to be true
      end

      it 'video/quicktime を許可する' do
        expect(described_class.allowed?('video/quicktime')).to be true
      end

      it 'audio/mpeg を許可する' do
        expect(described_class.allowed?('audio/mpeg')).to be true
      end

      it 'application/pdf を許可する' do
        expect(described_class.allowed?('application/pdf')).to be true
      end
    end

    context '許可されていないMIMEタイプの場合' do
      it 'application/javascript を拒否する' do
        expect(described_class.allowed?('application/javascript')).to be false
      end

      it 'application/x-executable を拒否する' do
        expect(described_class.allowed?('application/x-executable')).to be false
      end

      it 'text/html を拒否する' do
        expect(described_class.allowed?('text/html')).to be false
      end

      it 'application/zip を拒否する' do
        expect(described_class.allowed?('application/zip')).to be false
      end
    end
  end

  describe '.valid?' do
    let(:jpeg_content) { "\xFF\xD8\xFF\xE0\x00\x10JFIF" }
    let(:png_content) { "\x89PNG\r\n\x1A\n" }
    let(:gif_content) { "GIF89a" }

    def create_uploaded_file(content:, content_type:, filename:)
      tempfile = Tempfile.new(['test', File.extname(filename)])
      tempfile.binmode
      tempfile.write(content)
      tempfile.rewind

      ActionDispatch::Http::UploadedFile.new(
        tempfile: tempfile,
        filename: filename,
        type: content_type,
      )
    end

    context '有効なファイルの場合' do
      it 'JPEG ファイルを許可する' do
        file = create_uploaded_file(
          content: jpeg_content,
          content_type: 'image/jpeg',
          filename: 'test.jpg',
        )
        expect(described_class.valid?(file)).to be true
      end

      it 'PNG ファイルを許可する' do
        file = create_uploaded_file(
          content: png_content,
          content_type: 'image/png',
          filename: 'test.png',
        )
        expect(described_class.valid?(file)).to be true
      end

      it 'GIF ファイルを許可する' do
        file = create_uploaded_file(
          content: gif_content,
          content_type: 'image/gif',
          filename: 'test.gif',
        )
        expect(described_class.valid?(file)).to be true
      end
    end

    context '無効なファイルの場合' do
      it '許可されていないMIMEタイプを拒否する' do
        file = create_uploaded_file(
          content: 'alert("xss")',
          content_type: 'application/javascript',
          filename: 'malicious.js',
        )
        expect(described_class.valid?(file)).to be false
      end

      it 'MIMEタイプが偽装されたファイルを拒否する' do
        # JavaScript ファイルを image/jpeg と偽装
        file = create_uploaded_file(
          content: 'alert("xss")',
          content_type: 'image/jpeg',
          filename: 'fake.jpg',
        )
        expect(described_class.valid?(file)).to be false
      end
    end
  end

  describe '.validate!' do
    def create_uploaded_file(content:, content_type:, filename:)
      tempfile = Tempfile.new(['test', File.extname(filename)])
      tempfile.binmode
      tempfile.write(content)
      tempfile.rewind

      ActionDispatch::Http::UploadedFile.new(
        tempfile: tempfile,
        filename: filename,
        type: content_type,
      )
    end

    context '有効なファイルの場合' do
      it '例外を発生させない' do
        file = create_uploaded_file(
          content: "\xFF\xD8\xFF\xE0\x00\x10JFIF",
          content_type: 'image/jpeg',
          filename: 'test.jpg',
        )
        expect { described_class.validate!(file) }.not_to raise_error
      end
    end

    context '無効なファイルの場合' do
      it 'InvalidMimeTypeError を発生させる' do
        file = create_uploaded_file(
          content: 'alert("xss")',
          content_type: 'application/javascript',
          filename: 'malicious.js',
        )
        expect { described_class.validate!(file) }
          .to raise_error(described_class::InvalidMimeTypeError)
      end

      it 'エラーメッセージに許可された形式が含まれる' do
        file = create_uploaded_file(
          content: 'alert("xss")',
          content_type: 'application/javascript',
          filename: 'malicious.js',
        )
        expect { described_class.validate!(file) }
          .to raise_error(described_class::InvalidMimeTypeError, /JPEG.*PNG.*のみアップロードできます/)
      end
    end
  end

  describe '.allowed_extensions' do
    it '許可された拡張子のリストを返す' do
      extensions = described_class.allowed_extensions
      expect(extensions).to include('JPEG', 'PNG', 'GIF', 'WebP', 'SVG')
      expect(extensions).to include('MP4', 'WebM', 'MOV')
      expect(extensions).to include('MP3', 'WAV', 'OGG')
      expect(extensions).to include('PDF')
    end
  end
end
