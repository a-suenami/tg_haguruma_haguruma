import { useLexicalComposerContext } from '@lexical/react/LexicalComposerContext';
import { $insertNodes, $isRangeSelection, $getSelection } from 'lexical';
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