import { useLexicalComposerContext } from '@lexical/react/LexicalComposerContext';
import { $insertNodes, $isRangeSelection, $getSelection } from 'lexical';
import { useEffect } from 'react';
import { $createImageNode } from './ImageNode';
import { $createVideoNode } from './VideoNode';

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

      const handleDrop = (event: DragEvent) => {
        event.preventDefault();
        
        const files = event.dataTransfer?.files;
        if (!files || files.length === 0) return;

        const file = files[0];
        
        // Check if file is image or video
        if (!file.type.startsWith('image/') && !file.type.startsWith('video/')) {
          return;
        }

        const reader = new FileReader();
        reader.onload = (e) => {
          const src = e.target?.result as string;
          
          editor.update(() => {
            const selection = $getSelection();
            if ($isRangeSelection(selection)) {
              if (file.type.startsWith('image/')) {
                const imageNode = $createImageNode({
                  src,
                  altText: file.name,
                  maxWidth: 500,
                });
                $insertNodes([imageNode]);
              } else if (file.type.startsWith('video/')) {
                const videoNode = $createVideoNode({
                  src,
                });
                $insertNodes([videoNode]);
              }
            }
          });
        };
        
        reader.readAsDataURL(file);
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