import { useLexicalComposerContext } from '@lexical/react/LexicalComposerContext';
import { $insertNodes, $isRangeSelection, $getSelection, $getRoot, $createParagraphNode } from 'lexical';
import { useEffect } from 'react';
import { $createImageNode } from './ImageNode';
import { $createVideoNode } from './VideoNode';
import { uploadMedia, isImageFile, isVideoFile, isSupportedMediaFile } from '../utils/mediaUpload';

export default function FileDragDropPlugin(): null {
  const [editor] = useLexicalComposerContext();

  useEffect(() => {
    return editor.registerRootListener((rootElement: null | HTMLElement) => {
      if (rootElement === null) {
        return;
      }

      const handleDragOver = (event: DragEvent) => {
        event.preventDefault();
        event.dataTransfer!.dropEffect = 'copy';
      };

      const handleDrop = async (event: DragEvent) => {
        event.preventDefault();

        const files = event.dataTransfer?.files;
        if (!files || files.length === 0) return;

        const file = files[0];

        // Check if file is image or video
        if (!isSupportedMediaFile(file)) {
          return;
        }

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
        }
      };

      rootElement.addEventListener('dragover', handleDragOver);
      rootElement.addEventListener('drop', handleDrop);

      return () => {
        rootElement.removeEventListener('dragover', handleDragOver);
        rootElement.removeEventListener('drop', handleDrop);
      };
    });
  }, [editor]);

  return null;
}