# typed: false
# frozen_string_literal: true

require 'rails_helper'

describe LexicalJsonValidator do
  # Test model for validation
  let(:test_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :value

      validates :value, lexical_json: true

      def self.name
        'TestModel'
      end
    end
  end

  let(:model) { test_class.new }

  describe 'valid Lexical JSON' do
    it 'accepts empty paragraph structure' do
      model.value = {
        'root' => {
          'type' => 'root',
          'version' => 1,
          'children' => [
            {
              'type' => 'paragraph',
              'version' => 1,
              'children' => [],
            },
          ],
          'direction' => 'ltr',
          'format' => '',
          'indent' => 0,
        },
      }
      expect(model).to be_valid
    end

    it 'accepts paragraph with text' do
      model.value = {
        'root' => {
          'type' => 'root',
          'version' => 1,
          'children' => [
            {
              'type' => 'paragraph',
              'version' => 1,
              'children' => [
                {
                  'type' => 'text',
                  'version' => 1,
                  'text' => 'Hello World',
                  'format' => 0,
                  'style' => '',
                },
              ],
            },
          ],
          'direction' => 'ltr',
          'format' => '',
          'indent' => 0,
        },
      }
      expect(model).to be_valid
    end

    it 'accepts heading node' do
      model.value = {
        'root' => {
          'type' => 'root',
          'version' => 1,
          'children' => [
            {
              'type' => 'heading',
              'version' => 1,
              'tag' => 'h1',
              'children' => [
                {
                  'type' => 'text',
                  'version' => 1,
                  'text' => 'Title',
                },
              ],
            },
          ],
        },
      }
      expect(model).to be_valid
    end

    it 'accepts custom image node' do
      model.value = {
        'root' => {
          'type' => 'root',
          'version' => 1,
          'children' => [
            {
              'type' => 'image',
              'version' => 1,
              'src' => 'https://example.com/image.jpg',
              'altText' => 'Example image',
              'width' => 800,
              'height' => 600,
            },
          ],
        },
      }
      expect(model).to be_valid
    end

    it 'accepts custom video node' do
      model.value = {
        'root' => {
          'type' => 'root',
          'version' => 1,
          'children' => [
            {
              'type' => 'video',
              'version' => 1,
              'src' => 'https://example.com/video.mp4',
              'width' => 1280,
              'height' => 720,
            },
          ],
        },
      }
      expect(model).to be_valid
    end

    it 'accepts custom auto-embed node' do
      model.value = {
        'root' => {
          'type' => 'root',
          'version' => 1,
          'children' => [
            {
              'type' => 'auto-embed',
              'version' => 1,
              'embedType' => 'youtube',
              'url' => 'https://youtube.com/watch?v=abc123',
              'id' => 'abc123',
            },
          ],
        },
      }
      expect(model).to be_valid
    end

    it 'accepts list structure' do
      model.value = {
        'root' => {
          'type' => 'root',
          'version' => 1,
          'children' => [
            {
              'type' => 'list',
              'version' => 1,
              'listType' => 'bullet',
              'children' => [
                {
                  'type' => 'listitem',
                  'version' => 1,
                  'children' => [
                    { 'type' => 'text', 'version' => 1, 'text' => 'Item 1' },
                  ],
                },
              ],
            },
          ],
        },
      }
      expect(model).to be_valid
    end

    it 'accepts nil direction' do
      model.value = {
        'root' => {
          'type' => 'root',
          'version' => 1,
          'children' => [],
          'direction' => nil,
        },
      }
      expect(model).to be_valid
    end
  end

  describe 'invalid Lexical JSON' do
    it 'rejects missing root' do
      model.value = {
        'children' => [],
      }
      expect(model).not_to be_valid
      expect(model.errors[:value].first).to include('not a valid Lexical JSON structure')
    end

    it 'rejects root with wrong type' do
      model.value = {
        'root' => {
          'type' => 'document',
          'version' => 1,
          'children' => [],
        },
      }
      expect(model).not_to be_valid
      expect(model.errors[:value].first).to include('not a valid Lexical JSON structure')
    end

    it 'rejects root without children' do
      model.value = {
        'root' => {
          'type' => 'root',
          'version' => 1,
        },
      }
      expect(model).not_to be_valid
      expect(model.errors[:value].first).to include('not a valid Lexical JSON structure')
    end

    it 'rejects root without version' do
      model.value = {
        'root' => {
          'type' => 'root',
          'children' => [],
        },
      }
      expect(model).not_to be_valid
      expect(model.errors[:value].first).to include('not a valid Lexical JSON structure')
    end
  end

  describe 'ProseMirror format rejection' do
    it 'rejects ProseMirror format with doc root' do
      model.value = {
        'doc' => {
          'type' => 'doc',
          'content' => [
            {
              'type' => 'paragraph',
              'content' => [
                { 'type' => 'text', 'text' => 'Hello' },
              ],
            },
          ],
        },
      }
      expect(model).not_to be_valid
      expect(model.errors[:value].first).to include('ProseMirror format is not accepted')
    end

    it 'rejects ProseMirror format with type doc at top level' do
      model.value = {
        'type' => 'doc',
        'content' => [
          {
            'type' => 'paragraph',
            'content' => [
              { 'type' => 'text', 'text' => 'Hello' },
            ],
          },
        ],
      }
      expect(model).not_to be_valid
      expect(model.errors[:value].first).to include('ProseMirror format is not accepted')
    end
  end

  describe 'unknown node types' do
    it 'rejects unknown node types' do
      model.value = {
        'root' => {
          'type' => 'root',
          'version' => 1,
          'children' => [
            {
              'type' => 'custom-unknown-node',
              'version' => 1,
            },
          ],
        },
      }
      expect(model).not_to be_valid
      expect(model.errors[:value].first).to include('unknown node types')
      expect(model.errors[:value].first).to include('custom-unknown-node')
    end

    it 'detects nested unknown node types' do
      model.value = {
        'root' => {
          'type' => 'root',
          'version' => 1,
          'children' => [
            {
              'type' => 'paragraph',
              'version' => 1,
              'children' => [
                {
                  'type' => 'weird-inline-node',
                  'version' => 1,
                },
              ],
            },
          ],
        },
      }
      expect(model).not_to be_valid
      expect(model.errors[:value].first).to include('weird-inline-node')
    end
  end

  describe 'blank value handling' do
    it 'skips validation for nil value' do
      model.value = nil
      expect(model).to be_valid
    end

    it 'skips validation for empty hash' do
      model.value = {}
      expect(model).to be_valid
    end
  end
end
