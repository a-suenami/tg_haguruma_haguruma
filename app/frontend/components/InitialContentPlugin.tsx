import { useEffect, useRef } from 'react';
import { useLexicalComposerContext } from '@lexical/react/LexicalComposerContext';
import { $getRoot, $insertNodes } from 'lexical';
import { $generateNodesFromDOM } from '@lexical/html';

interface InitialContentPluginProps {
  content: string;
}

export default function InitialContentPlugin({
  content,
}: InitialContentPluginProps): null {
  const [editor] = useLexicalComposerContext();
  const isInitialized = useRef(false);

  useEffect(() => {
    // Only run once on initial mount
    if (isInitialized.current || !content) {
      return;
    }
    isInitialized.current = true;

    editor.update(() => {
      const parser = new DOMParser();
      const dom = parser.parseFromString(content, 'text/html');
      const nodes = $generateNodesFromDOM(editor, dom);

      const root = $getRoot();
      root.clear();
      root.append(...nodes);
    });
  }, [editor, content]);

  return null;
}
