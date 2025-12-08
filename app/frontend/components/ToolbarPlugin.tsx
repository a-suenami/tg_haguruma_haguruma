import type { FC } from "react";
import { useState } from "react";
import { $getSelection, $isRangeSelection, FORMAT_TEXT_COMMAND, $insertNodes } from "lexical";
import { useLexicalComposerContext } from "@lexical/react/LexicalComposerContext";
import { $setBlocksType } from "@lexical/selection";
import { $createHeadingNode, $createQuoteNode } from "@lexical/rich-text";
import { INSERT_ORDERED_LIST_COMMAND, INSERT_UNORDERED_LIST_COMMAND } from "@lexical/list";
import { $createCodeNode } from "@lexical/code";
import { $createImageNode } from "./ImageNode";
import { $createVideoNode } from "./VideoNode";
import { parseAnyEmbedUrl } from "./EmbedConfigs";
import { $patchStyleText } from "@lexical/selection";
import InlineColorPicker from "./InlineColorPicker";
import { uploadMedia, isImageFile, isVideoFile, isSupportedMediaFile } from "../utils/mediaUpload";

const ToolbarPlugin: FC = () => {
  const [editor] = useLexicalComposerContext();
  const [isUploading, setIsUploading] = useState(false);

  const formatText = (format: 'bold' | 'italic' | 'underline' | 'strikethrough' | 'code') => {
    editor.dispatchCommand(FORMAT_TEXT_COMMAND, format);
  };

  const formatHeading = (headingSize: 'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6') => {
    editor.update(() => {
      const selection = $getSelection();
      if ($isRangeSelection(selection)) {
        $setBlocksType(selection, () => $createHeadingNode(headingSize));
      }
    });
  };

  const formatQuote = () => {
    editor.update(() => {
      const selection = $getSelection();
      if ($isRangeSelection(selection)) {
        $setBlocksType(selection, () => $createQuoteNode());
      }
    });
  };

  const formatCodeBlock = () => {
    editor.update(() => {
      const selection = $getSelection();
      if ($isRangeSelection(selection)) {
        $setBlocksType(selection, () => $createCodeNode());
      }
    });
  };

  const formatList = (type: 'bullet' | 'number') => {
    if (type === 'bullet') {
      editor.dispatchCommand(INSERT_UNORDERED_LIST_COMMAND, undefined);
    } else {
      editor.dispatchCommand(INSERT_ORDERED_LIST_COMMAND, undefined);
    }
  };

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const files = event.target.files;
    if (!files || files.length === 0) return;

    const file = files[0];
    if (!isSupportedMediaFile(file)) {
      alert('画像または動画ファイルを選択してください');
      event.target.value = '';
      return;
    }

    setIsUploading(true);

    try {
      // Upload to S3 and get CloudFront URL
      const result = await uploadMedia(file);

      editor.update(() => {
        const selection = $getSelection();
        if ($isRangeSelection(selection)) {
          if (isImageFile(file)) {
            const imageNode = $createImageNode({
              src: result.url,
              altText: file.name,
              maxWidth: 500,
            });
            $insertNodes([imageNode]);
          } else if (isVideoFile(file)) {
            const videoNode = $createVideoNode({
              src: result.url,
            });
            $insertNodes([videoNode]);
          }
        }
      });
    } catch (error) {
      console.error('Upload failed:', error);
      alert('アップロードに失敗しました');
    } finally {
      setIsUploading(false);
      // Reset input
      event.target.value = '';
    }
  };

  const applyTextColor = (color: string) => {
    editor.update(() => {
      const selection = $getSelection();
      if ($isRangeSelection(selection)) {
        $patchStyleText(selection, {
          color: color,
        });
      }
    });
  };

  const insertEmbed = () => {
    const url = prompt('Enter URL to embed (YouTube, Twitter, etc.):');
    if (url) {
      const parsedEmbed = parseAnyEmbedUrl(url);
      if (parsedEmbed) {
        parsedEmbed.config.insertNode(editor, parsedEmbed.result);
      } else {
        alert('URL not supported. Currently supports YouTube and Twitter URLs.');
      }
    }
  };

  return (
    <div className="toolbar">
      <button
        type="button"
        onClick={() => formatText('bold')}
        className="toolbar-item"
      >
        <b>B</b>
      </button>
      <button
        type="button"
        onClick={() => formatText('italic')}
        className="toolbar-item"
      >
        <i>I</i>
      </button>
      <button
        type="button"
        onClick={() => formatText('underline')}
        className="toolbar-item"
      >
        <u>U</u>
      </button>
      <button
        type="button"
        onClick={() => formatText('strikethrough')}
        className="toolbar-item"
      >
        <s>S</s>
      </button>
      <button
        type="button"
        onClick={() => formatText('code')}
        className="toolbar-item"
      >
        {'</>'}
      </button>

      <div className="toolbar-divider" />

      <div className="color-picker-container">
        <span style={{ fontSize: '12px', marginRight: '8px' }}>Text Color:</span>
        <InlineColorPicker onColorSelect={applyTextColor} />
      </div>
      
      <div className="toolbar-divider" />
      
      <select
        onChange={(e) => {
          const value = e.target.value;
          if (value === 'h1' || value === 'h2' || value === 'h3' || value === 'h4' || value === 'h5' || value === 'h6') {
            formatHeading(value);
          } else if (value === 'quote') {
            formatQuote();
          } else if (value === 'code') {
            formatCodeBlock();
          }
        }}
        className="toolbar-select"
        defaultValue=""
      >
        <option value="" disabled>Format</option>
        <option value="h1">Heading 1</option>
        <option value="h2">Heading 2</option>
        <option value="h3">Heading 3</option>
        <option value="h4">Heading 4</option>
        <option value="h5">Heading 5</option>
        <option value="h6">Heading 6</option>
        <option value="quote">Quote</option>
        <option value="code">Code Block</option>
      </select>

      <div className="toolbar-divider" />

      <button
        onClick={() => formatList('bullet')}
        className="toolbar-item"
      >
        • List
      </button>
      <button
        onClick={() => formatList('number')}
        className="toolbar-item"
      >
        1. List
      </button>

      <div className="toolbar-divider" />

      <label className={`toolbar-item file-upload-button ${isUploading ? 'uploading' : ''}`}>
        {isUploading ? '⏳ Uploading...' : '📁 Upload'}
        <input
          type="file"
          accept="image/*,video/*"
          onChange={handleFileUpload}
          disabled={isUploading}
          style={{ display: 'none' }}
        />
      </label>

      <div className="toolbar-divider" />

      <button
        onClick={insertEmbed}
        className="toolbar-item"
        title="Insert embed (YouTube, Twitter, etc.)"
      >
        🔗 Embed
      </button>
    </div>
  );
};

export default ToolbarPlugin;