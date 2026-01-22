import type { FC } from "react";
import { useState } from "react";
import { $getSelection, $isRangeSelection, FORMAT_TEXT_COMMAND, $insertNodes, $getRoot, $createParagraphNode, $createTextNode } from "lexical";
import { useLexicalComposerContext } from "@lexical/react/LexicalComposerContext";
import { $setBlocksType } from "@lexical/selection";
import { $createHeadingNode, $createQuoteNode } from "@lexical/rich-text";
import { INSERT_ORDERED_LIST_COMMAND, INSERT_UNORDERED_LIST_COMMAND } from "@lexical/list";
import { $createCodeNode } from "@lexical/code";
import { $createImageNode } from "./ImageNode";
import { $createVideoNode } from "./VideoNode";
import { parseAnyEmbedUrl } from "./EmbedConfigs";
import InlineColorPicker from "./InlineColorPicker";
import { TOGGLE_LINK_COMMAND } from '@lexical/link';
import { uploadMedia, isImageFile, isVideoFile, isSupportedMediaFile } from "../utils/mediaUpload";
import {
  Bold,
  Italic,
  Underline,
  Strikethrough,
  Upload,
  Loader2,
  Link,
  Unlink,
  FileVideo,
  List,
  ListOrdered,
} from "lucide-react";

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
      if (!$isRangeSelection(selection)) return;

      // Collect unique top-level elements (paragraphs) in selection order
      const nodes = selection.getNodes();
      const seenKeys = new Set<string>();
      const topLevelElements: ReturnType<typeof nodes[0]['getTopLevelElement']>[] = [];

      nodes.forEach((node) => {
        const topLevel = node.getTopLevelElement();
        if (topLevel && !seenKeys.has(topLevel.getKey())) {
          seenKeys.add(topLevel.getKey());
          topLevelElements.push(topLevel);
        }
      });

      if (topLevelElements.length === 0) return;

      // Collect text content from all paragraphs
      const textLines = topLevelElements.map((el) => el?.getTextContent() || '');
      const codeContent = textLines.join('\n');

      // Create a single code node with the combined content
      const codeNode = $createCodeNode();
      codeNode.append($createTextNode(codeContent));

      // Insert code node before the first paragraph
      const firstElement = topLevelElements[0];
      if (firstElement) {
        firstElement.insertBefore(codeNode);
      }

      // Remove all original paragraphs
      topLevelElements.forEach((el) => {
        if (el) {
          el.remove();
        }
      });

      // Select the end of the code node
      codeNode.selectEnd();
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
        // 挿入するノードを作成
        let nodeToInsert;
        if (isImageFile(file)) {
          nodeToInsert = $createImageNode({
            src: result.url,
            altText: file.name,
            maxWidth: 500,
          });
        } else if (isVideoFile(file)) {
          nodeToInsert = $createVideoNode({
            src: result.url,
          });
        }

        if (nodeToInsert) {
          // 有効なセレクションがあればそこに挿入、なければ末尾に追加
          const selection = $getSelection();
          if ($isRangeSelection(selection)) {
            $insertNodes([nodeToInsert]);
          } else {
            // セレクションがない場合、ドキュメント末尾に挿入
            const root = $getRoot();
            root.append(nodeToInsert);
            // 画像/動画の後に空のパラグラフを追加してカーソル位置を確保
            const paragraph = $createParagraphNode();
            root.append(paragraph);
            paragraph.select();
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

  const insertLink = () => {
    const url = prompt('Enter link URL:');
    if (url) {
      editor.dispatchCommand(TOGGLE_LINK_COMMAND, url);
    }
  };

  const removeLink = () => {
    editor.dispatchCommand(TOGGLE_LINK_COMMAND, null);
  };

  return (
    <div className="toolbar">
      <button
        type="button"
        onClick={() => formatText('bold')}
        className="toolbar-item"
        title="Bold"
      >
        <Bold size={16} />
      </button>
      <button
        type="button"
        onClick={() => formatText('italic')}
        className="toolbar-item"
        title="Italic"
      >
        <Italic size={16} />
      </button>
      <button
        type="button"
        onClick={() => formatText('underline')}
        className="toolbar-item"
        title="Underline"
      >
        <Underline size={16} />
      </button>
      <button
        type="button"
        onClick={() => formatText('strikethrough')}
        className="toolbar-item"
        title="Strikethrough"
      >
        <Strikethrough size={16} />
      </button>

      <div className="toolbar-divider" />

      <button
        type="button"
        onClick={insertLink}
        className="toolbar-item"
        title="Insert link"
      >
        <Link size={16} />
      </button>
      <button
        type="button"
        onClick={removeLink}
        className="toolbar-item"
        title="Remove link"
      >
        <Unlink size={16} />
      </button>

      <div className="toolbar-divider" />

      <InlineColorPicker editor={editor} />

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
        type="button"
        onClick={() => formatList('bullet')}
        className="toolbar-item"
        title="Bullet List"
      >
        <List size={16} />
      </button>
      <button
        type="button"
        onClick={() => formatList('number')}
        className="toolbar-item"
        title="Numbered List"
      >
        <ListOrdered size={16} />
      </button>

      <div className="toolbar-divider" />

      <label
        className={`toolbar-item file-upload-button ${isUploading ? 'uploading' : ''}`}
        title="Upload image or video"
      >
        {isUploading ? <Loader2 size={16} className="animate-spin" /> : <Upload size={16} />}
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
        type="button"
        onClick={insertEmbed}
        className="toolbar-item"
        title="Insert embed (YouTube, Twitter, etc.)"
      >
        <FileVideo size={16} />
      </button>
    </div>
  );
};

export default ToolbarPlugin;
