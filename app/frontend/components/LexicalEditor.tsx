import React, { useEffect } from 'react';
import { LexicalComposer } from '@lexical/react/LexicalComposer';
import { RichTextPlugin } from '@lexical/react/LexicalRichTextPlugin';
import { ContentEditable } from '@lexical/react/LexicalContentEditable';
import { HistoryPlugin } from '@lexical/react/LexicalHistoryPlugin';
import { useLexicalComposerContext } from '@lexical/react/LexicalComposerContext';
import { LexicalErrorBoundary } from '@lexical/react/LexicalErrorBoundary';
import { 
  $getRoot, 
  $getSelection,
  $createParagraphNode, 
  $createTextNode,
  FORMAT_TEXT_COMMAND
} from 'lexical';
import { $generateHtmlFromNodes, $generateNodesFromDOM } from '@lexical/html';
import { ListPlugin } from '@lexical/react/LexicalListPlugin';
import { ListNode, ListItemNode } from '@lexical/list';
import { 
  $createHeadingNode,
  HeadingTagType,
  HeadingNode, 
  QuoteNode 
} from '@lexical/rich-text';

// Lexical nodes
const editorNodes = [
  HeadingNode,
  ListNode,
  ListItemNode,
  QuoteNode,
];

// Theme configuration
const theme = {
  heading: {
    h1: 'editor-heading-h1',
    h2: 'editor-heading-h2', 
    h3: 'editor-heading-h3',
    h4: 'editor-heading-h4',
    h5: 'editor-heading-h5',
    h6: 'editor-heading-h6',
  },
  list: {
    ol: 'editor-list-ol',
    ul: 'editor-list-ul',
    listitem: 'editor-listitem',
  },
  text: {
    bold: 'editor-text-bold',
    italic: 'editor-text-italic',
    underline: 'editor-text-underline',
    strikethrough: 'editor-text-strikethrough',
  },
  paragraph: 'editor-paragraph',
};

interface LexicalEditorProps {
  initialContent?: string;
  placeholder?: string;
  hiddenFieldId?: string;
}

// Content sync component
function ContentSyncPlugin({ hiddenFieldId }: { hiddenFieldId?: string }) {
  const [editor] = useLexicalComposerContext();

  useEffect(() => {
    if (!hiddenFieldId) return;

    return editor.registerUpdateListener(({ editorState }) => {
      editorState.read(() => {
        const htmlString = $generateHtmlFromNodes(editor);
        const hiddenField = document.getElementById(hiddenFieldId) as HTMLInputElement;
        if (hiddenField) {
          hiddenField.value = htmlString;
          // Trigger input event for form validation
          hiddenField.dispatchEvent(new Event('input', { bubbles: true }));
        }
      });
    });
  }, [editor, hiddenFieldId]);

  return null;
}

// Initial content plugin
function InitialContentPlugin({ initialContent }: { initialContent?: string }) {
  const [editor] = useLexicalComposerContext();

  useEffect(() => {
    if (!initialContent) return;

    editor.update(() => {
      try {
        const parser = new DOMParser();
        const dom = parser.parseFromString(initialContent, 'text/html');
        const nodes = $generateNodesFromDOM(editor, dom);
        $getRoot().clear();
        $getRoot().append(...nodes);
      } catch (error) {
        console.error('Error setting initial content:', error);
        // Fallback to simple text
        $getRoot().clear();
        const paragraph = $createParagraphNode();
        paragraph.append($createTextNode(initialContent));
        $getRoot().append(paragraph);
      }
    });
  }, [editor, initialContent]);

  return null;
}

// Toolbar component
function ToolbarPlugin() {
  const [editor] = useLexicalComposerContext();

  const formatText = (format: 'bold' | 'italic' | 'underline') => {
    editor.dispatchCommand(FORMAT_TEXT_COMMAND, format);
  };

  const insertHeading = (level: number) => {
    editor.update(() => {
      const selection = $getSelection();
      if (selection) {
        const headingNode = $createHeadingNode(`h${level}` as HeadingTagType);
        selection.insertNodes([headingNode]);
      }
    });
  };

  return (
    <div className="lexical-toolbar">
      <div className="toolbar-group">
        <button 
          type="button" 
          className="toolbar-btn"
          onClick={() => formatText('bold')}
        >
          <i className="fas fa-bold"></i>
        </button>
        <button 
          type="button" 
          className="toolbar-btn"
          onClick={() => formatText('italic')}
        >
          <i className="fas fa-italic"></i>
        </button>
        <button 
          type="button" 
          className="toolbar-btn"
          onClick={() => formatText('underline')}
        >
          <i className="fas fa-underline"></i>
        </button>
      </div>
      
      <div className="toolbar-group">
        <button 
          type="button" 
          className="toolbar-btn"
          onClick={() => insertHeading(2)}
        >
          <i className="fas fa-heading"></i>
        </button>
      </div>
    </div>
  );
}

// Main editor component
export default function LexicalEditor({ 
  initialContent, 
  placeholder = '記事の内容を入力してください...', 
  hiddenFieldId 
}: LexicalEditorProps) {
  const initialConfig = {
    namespace: 'LexicalEditor',
    theme,
    nodes: editorNodes,
    onError: (error: Error) => {
      console.error('Lexical error:', error);
    },
  };

  return (
    <LexicalComposer initialConfig={initialConfig}>
      <div className="lexical-editor-wrapper">
        <ToolbarPlugin />
        <div className="lexical-editor-container">
          <RichTextPlugin
            contentEditable={
              <ContentEditable 
                className="lexical-editor" 
                style={{ outline: 'none' }}
              />
            }
            placeholder={
              <div className="lexical-editor-placeholder">{placeholder}</div>
            }
            ErrorBoundary={LexicalErrorBoundary}
          />
        </div>
        <HistoryPlugin />
        <ListPlugin />
        {initialContent && <InitialContentPlugin initialContent={initialContent} />}
        {hiddenFieldId && <ContentSyncPlugin hiddenFieldId={hiddenFieldId} />}
      </div>
    </LexicalComposer>
  );
}