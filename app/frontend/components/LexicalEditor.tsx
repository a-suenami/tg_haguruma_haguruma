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
import { LexicalTypeaheadMenuPlugin, MenuOption, useBasicTypeaheadTriggerMatch } from '@lexical/react/LexicalTypeaheadMenuPlugin';
import { LinkPlugin } from '@lexical/react/LexicalLinkPlugin';
import { 
  ListNode, 
  ListItemNode,
  $createListNode,
  $createListItemNode
} from '@lexical/list';
import { 
  $createHeadingNode,
  $createQuoteNode,
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
    code: 'editor-text-code',
  },
  quote: 'editor-quote',
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

// Floating Toolbar component (Notion-like)
function FloatingToolbarPlugin() {
  const [editor] = useLexicalComposerContext();
  const [isVisible, setIsVisible] = React.useState(false);
  const [position, setPosition] = React.useState({ top: 0, left: 0 });

  React.useEffect(() => {
    return editor.registerUpdateListener(() => {
      editor.getEditorState().read(() => {
        const selection = $getSelection();
        
        if (selection && selection.getTextContent().trim() !== '') {
          // Get selection bounds for positioning
          const nativeSelection = window.getSelection();
          if (nativeSelection && nativeSelection.rangeCount > 0) {
            const range = nativeSelection.getRangeAt(0);
            const rect = range.getBoundingClientRect();
            
            setPosition({
              top: rect.top - 50,
              left: rect.left + rect.width / 2,
            });
            setIsVisible(true);
          }
        } else {
          setIsVisible(false);
        }
      });
    });
  }, [editor]);

  if (!isVisible) return null;

  const formatText = (format: 'bold' | 'italic' | 'underline' | 'strikethrough' | 'code') => {
    editor.dispatchCommand(FORMAT_TEXT_COMMAND, format);
  };

  return (
    <div 
      className="floating-toolbar"
      style={{
        position: 'fixed',
        top: position.top,
        left: position.left,
        transform: 'translateX(-50%)',
      }}
    >
      <button 
        type="button" 
        className="floating-btn"
        onClick={() => formatText('bold')}
      >
        <i className="fas fa-bold"></i>
      </button>
      <button 
        type="button" 
        className="floating-btn"
        onClick={() => formatText('italic')}
      >
        <i className="fas fa-italic"></i>
      </button>
      <button 
        type="button" 
        className="floating-btn"
        onClick={() => formatText('underline')}
      >
        <i className="fas fa-underline"></i>
      </button>
      <button 
        type="button" 
        className="floating-btn"
        onClick={() => formatText('strikethrough')}
      >
        <i className="fas fa-strikethrough"></i>
      </button>
      <button 
        type="button" 
        className="floating-btn"
        onClick={() => formatText('code')}
      >
        <i className="fas fa-code"></i>
      </button>
    </div>
  );
}

// Slash Commands Menu
class SlashCommandOption extends MenuOption {
  title: string;
  icon: string;
  onSelect: () => void;

  constructor(title: string, icon: string, onSelect: () => void) {
    super(title);
    this.title = title;
    this.icon = icon;
    this.onSelect = onSelect;
  }
}

function SlashCommandsPlugin() {
  const [editor] = useLexicalComposerContext();
  const checkForTriggerMatch = useBasicTypeaheadTriggerMatch('/', {
    minLength: 0,
  });

  const options = React.useMemo(() => {
    const baseOptions = [
      new SlashCommandOption('見出し1', '📝', () => {
        editor.update(() => {
          const selection = $getSelection();
          if (selection) {
            const headingNode = $createHeadingNode('h1');
            selection.insertNodes([headingNode]);
          }
        });
      }),
      new SlashCommandOption('見出し2', '📝', () => {
        editor.update(() => {
          const selection = $getSelection();
          if (selection) {
            const headingNode = $createHeadingNode('h2');
            selection.insertNodes([headingNode]);
          }
        });
      }),
      new SlashCommandOption('見出し3', '📝', () => {
        editor.update(() => {
          const selection = $getSelection();
          if (selection) {
            const headingNode = $createHeadingNode('h3');
            selection.insertNodes([headingNode]);
          }
        });
      }),
      new SlashCommandOption('箇条書き', '•', () => {
        editor.update(() => {
          const selection = $getSelection();
          if (selection) {
            const listNode = $createListNode('ul');
            const listItemNode = $createListItemNode();
            listNode.append(listItemNode);
            selection.insertNodes([listNode]);
          }
        });
      }),
      new SlashCommandOption('番号付きリスト', '1.', () => {
        editor.update(() => {
          const selection = $getSelection();
          if (selection) {
            const listNode = $createListNode('ol');
            const listItemNode = $createListItemNode();
            listNode.append(listItemNode);
            selection.insertNodes([listNode]);
          }
        });
      }),
      new SlashCommandOption('引用', '💬', () => {
        editor.update(() => {
          const selection = $getSelection();
          if (selection) {
            const quoteNode = $createQuoteNode();
            selection.insertNodes([quoteNode]);
          }
        });
      }),
    ];
    return baseOptions;
  }, [editor]);

  return (
    <LexicalTypeaheadMenuPlugin<SlashCommandOption>
      onQueryChange={() => {}}
      onSelectOption={(option) => {
        option.onSelect();
      }}
      triggerFn={checkForTriggerMatch}
      options={options}
      menuRenderFn={(anchorElementRef, { selectedIndex, selectOptionAndCleanUp, setHighlightedIndex }) => {
        if (!anchorElementRef.current) return null;

        return (
          <div className="slash-commands-menu">
            {options.map((option, index) => (
              <div
                key={option.key}
                className={`slash-command-item ${index === selectedIndex ? 'selected' : ''}`}
                onClick={() => selectOptionAndCleanUp(option)}
                onMouseEnter={() => setHighlightedIndex(index)}
              >
                <span className="slash-command-icon">{option.icon}</span>
                <span className="slash-command-title">{option.title}</span>
              </div>
            ))}
          </div>
        );
      }}
    />
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
        <FloatingToolbarPlugin />
        <HistoryPlugin />
        <ListPlugin />
        <LinkPlugin />
        <SlashCommandsPlugin />
        {initialContent && <InitialContentPlugin initialContent={initialContent} />}
        {hiddenFieldId && <ContentSyncPlugin hiddenFieldId={hiddenFieldId} />}
      </div>
    </LexicalComposer>
  );
}