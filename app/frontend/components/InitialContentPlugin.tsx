import { useEffect, useRef } from 'react';
import { useLexicalComposerContext } from '@lexical/react/LexicalComposerContext';
import { $getRoot, $createParagraphNode, $createTextNode } from 'lexical';

interface InitialContentPluginProps {
  content: string;
}

// Extract plain text from ProseMirror JSON format
function extractTextFromProseMirror(node: any): string {
  if (!node) return '';

  if (node.type === 'text' && node.text) {
    return node.text;
  }

  if (node.content && Array.isArray(node.content)) {
    return node.content.map(extractTextFromProseMirror).join('');
  }

  return '';
}

// Check if content is ProseMirror format
function isProseMirrorFormat(data: any): boolean {
  return data && data.type === 'doc' && Array.isArray(data.content);
}

// Check if content is Lexical format
function isLexicalFormat(data: any): boolean {
  return data && data.root && data.root.type === 'root';
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

    try {
      const parsed = JSON.parse(content);

      if (isLexicalFormat(parsed)) {
        // Lexical JSON format - parse directly
        const editorState = editor.parseEditorState(content);
        editor.setEditorState(editorState);
      } else if (isProseMirrorFormat(parsed)) {
        // ProseMirror format - extract text and create simple content
        const textContent = extractTextFromProseMirror(parsed);
        if (textContent) {
          editor.update(() => {
            const root = $getRoot();
            root.clear();
            const paragraph = $createParagraphNode();
            paragraph.append($createTextNode(textContent));
            root.append(paragraph);
          });
        }
      } else {
        console.warn('Unknown content format:', parsed);
      }
    } catch (e) {
      console.error('Failed to parse initial content:', e);
    }
  }, [editor, content]);

  return null;
}
