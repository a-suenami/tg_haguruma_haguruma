import React, { useEffect, useCallback, useState } from 'react';
import { LexicalComposer } from '@lexical/react/LexicalComposer';
import { RichTextPlugin } from '@lexical/react/LexicalRichTextPlugin';
import { ContentEditable } from '@lexical/react/LexicalContentEditable';
import { HistoryPlugin } from '@lexical/react/LexicalHistoryPlugin';
import { useLexicalComposerContext } from '@lexical/react/LexicalComposerContext';
import { LexicalErrorBoundary } from '@lexical/react/LexicalErrorBoundary';
// ToolbarPlugin is not needed for custom toolbar
import { CheckListPlugin } from '@lexical/react/LexicalCheckListPlugin';
import { TabIndentationPlugin } from '@lexical/react/LexicalTabIndentationPlugin';
import {
  $getRoot,
  $getSelection,
  $createParagraphNode,
  $createTextNode,
  FORMAT_TEXT_COMMAND,
  ParagraphNode,
  TextNode,
  $isRangeSelection,
  $getNodeByKey,
  SELECTION_CHANGE_COMMAND,
  COMMAND_PRIORITY_CRITICAL,
  KEY_MODIFIER_COMMAND
} from 'lexical';
import { $generateHtmlFromNodes, $generateNodesFromDOM } from '@lexical/html';
import { ListPlugin } from '@lexical/react/LexicalListPlugin';
import { LexicalTypeaheadMenuPlugin, MenuOption, useBasicTypeaheadTriggerMatch } from '@lexical/react/LexicalTypeaheadMenuPlugin';
import { LinkPlugin } from '@lexical/react/LexicalLinkPlugin';
import {
  ListNode,
  ListItemNode,
  $createListNode,
  $createListItemNode,
  $isListNode,
  INSERT_ORDERED_LIST_COMMAND,
  INSERT_UNORDERED_LIST_COMMAND,
  REMOVE_LIST_COMMAND
} from '@lexical/list';
import {
  $createHeadingNode,
  $createQuoteNode,
  HeadingTagType,
  HeadingNode,
  QuoteNode,
  $isHeadingNode
} from '@lexical/rich-text';
import { LinkNode, $createLinkNode } from '@lexical/link';
import { CodeNode, $createCodeNode } from '@lexical/code';

// Lexical nodes
const editorNodes = [
  ParagraphNode,
  TextNode,
  HeadingNode,
  ListNode,
  ListItemNode,
  QuoteNode,
  LinkNode,
  CodeNode,
];

// Theme configuration (Playground-style)
const theme = {
  ltr: 'ltr',
  rtl: 'rtl',
  placeholder: 'editor-placeholder',
  paragraph: 'editor-paragraph',
  quote: 'editor-quote',
  heading: {
    h1: 'editor-heading-h1',
    h2: 'editor-heading-h2',
    h3: 'editor-heading-h3',
    h4: 'editor-heading-h4',
    h5: 'editor-heading-h5',
    h6: 'editor-heading-h6',
  },
  list: {
    listitem: 'editor-listitem',
    nested: {
      listitem: 'editor-nested-listitem',
    },
    ol: 'editor-list-ol',
    ul: 'editor-list-ul',
  },
  image: 'editor-image',
  link: 'editor-link',
  text: {
    bold: 'editor-text-bold',
    code: 'editor-text-code',
    hashtag: 'editor-text-hashtag',
    italic: 'editor-text-italic',
    strikethrough: 'editor-text-strikethrough',
    subscript: 'editor-text-subscript',
    superscript: 'editor-text-superscript',
    underline: 'editor-text-underline',
    underlineStrikethrough: 'editor-text-underlineStrikethrough',
  },
  code: 'editor-code',
  codeHighlight: {
    atrule: 'editor-tokenAttr',
    attr: 'editor-tokenAttr',
    boolean: 'editor-tokenProperty',
    builtin: 'editor-tokenSelector',
    cdata: 'editor-tokenComment',
    char: 'editor-tokenSelector',
    class: 'editor-tokenFunction',
    'class-name': 'editor-tokenFunction',
    comment: 'editor-tokenComment',
    constant: 'editor-tokenProperty',
    deleted: 'editor-tokenProperty',
    doctype: 'editor-tokenComment',
    entity: 'editor-tokenOperator',
    function: 'editor-tokenFunction',
    important: 'editor-tokenVariable',
    inserted: 'editor-tokenSelector',
    keyword: 'editor-tokenAttr',
    namespace: 'editor-tokenVariable',
    number: 'editor-tokenProperty',
    operator: 'editor-tokenOperator',
    prolog: 'editor-tokenComment',
    property: 'editor-tokenProperty',
    punctuation: 'editor-tokenPunctuation',
    regex: 'editor-tokenVariable',
    selector: 'editor-tokenSelector',
    string: 'editor-tokenSelector',
    symbol: 'editor-tokenProperty',
    tag: 'editor-tokenProperty',
    url: 'editor-tokenOperator',
    variable: 'editor-tokenVariable',
  },
};

interface LexicalEditorProps {
  initialContent?: string;
  placeholder?: string;
  hiddenFieldId?: string;
}

// Rich Text Editor Toolbar Component
function RichTextToolbarPlugin() {
  const [editor] = useLexicalComposerContext();
  const [canUndo, setCanUndo] = useState(false);
  const [canRedo, setCanRedo] = useState(false);
  const [isBold, setIsBold] = useState(false);
  const [isItalic, setIsItalic] = useState(false);
  const [isUnderline, setIsUnderline] = useState(false);
  const [isStrikethrough, setIsStrikethrough] = useState(false);
  const [isCode, setIsCode] = useState(false);

  const updateToolbar = useCallback(() => {
    const selection = $getSelection();
    if ($isRangeSelection(selection)) {
      setIsBold(selection.hasFormat('bold'));
      setIsItalic(selection.hasFormat('italic'));
      setIsUnderline(selection.hasFormat('underline'));
      setIsStrikethrough(selection.hasFormat('strikethrough'));
      setIsCode(selection.hasFormat('code'));
    }
  }, []);

  useEffect(() => {
    return editor.registerUpdateListener(({ editorState }) => {
      editorState.read(() => {
        updateToolbar();
      });
    });
  }, [editor, updateToolbar]);

  const formatText = (format: 'bold' | 'italic' | 'underline' | 'strikethrough' | 'code') => {
    editor.dispatchCommand(FORMAT_TEXT_COMMAND, format);
  };

  const insertHeading = (headingSize: HeadingTagType) => {
    editor.update(() => {
      const selection = $getSelection();
      if ($isRangeSelection(selection)) {
        const headingNode = $createHeadingNode(headingSize);
        selection.insertNodes([headingNode]);
      }
    });
  };

  const insertList = (listType: 'bullet' | 'number') => {
    if (listType === 'bullet') {
      editor.dispatchCommand(INSERT_UNORDERED_LIST_COMMAND, undefined);
    } else {
      editor.dispatchCommand(INSERT_ORDERED_LIST_COMMAND, undefined);
    }
  };

  const insertQuote = () => {
    editor.update(() => {
      const selection = $getSelection();
      if ($isRangeSelection(selection)) {
        const quoteNode = $createQuoteNode();
        selection.insertNodes([quoteNode]);
      }
    });
  };

  const insertCode = () => {
    editor.update(() => {
      const selection = $getSelection();
      if ($isRangeSelection(selection)) {
        const codeNode = $createCodeNode();
        selection.insertNodes([codeNode]);
      }
    });
  };

  return (
    <div className="rich-text-toolbar">
      <div className="toolbar-section">
        <button
          type="button"
          className={`toolbar-btn ${isBold ? 'active' : ''}`}
          onClick={() => formatText('bold')}
          title="Bold (Ctrl+B)"
        >
          <i className="fas fa-bold"></i>
        </button>
        <button
          type="button"
          className={`toolbar-btn ${isItalic ? 'active' : ''}`}
          onClick={() => formatText('italic')}
          title="Italic (Ctrl+I)"
        >
          <i className="fas fa-italic"></i>
        </button>
        <button
          type="button"
          className={`toolbar-btn ${isUnderline ? 'active' : ''}`}
          onClick={() => formatText('underline')}
          title="Underline (Ctrl+U)"
        >
          <i className="fas fa-underline"></i>
        </button>
        <button
          type="button"
          className={`toolbar-btn ${isStrikethrough ? 'active' : ''}`}
          onClick={() => formatText('strikethrough')}
          title="Strikethrough"
        >
          <i className="fas fa-strikethrough"></i>
        </button>
        <button
          type="button"
          className={`toolbar-btn ${isCode ? 'active' : ''}`}
          onClick={() => formatText('code')}
          title="Code"
        >
          <i className="fas fa-code"></i>
        </button>
      </div>

      <div className="toolbar-divider"></div>

      <div className="toolbar-section">
        <button
          type="button"
          className="toolbar-btn"
          onClick={() => insertHeading('h1')}
          title="Heading 1"
        >
          H1
        </button>
        <button
          type="button"
          className="toolbar-btn"
          onClick={() => insertHeading('h2')}
          title="Heading 2"
        >
          H2
        </button>
        <button
          type="button"
          className="toolbar-btn"
          onClick={() => insertHeading('h3')}
          title="Heading 3"
        >
          H3
        </button>
      </div>

      <div className="toolbar-divider"></div>

      <div className="toolbar-section">
        <button
          type="button"
          className="toolbar-btn"
          onClick={() => insertList('bullet')}
          title="Bullet List"
        >
          <i className="fas fa-list-ul"></i>
        </button>
        <button
          type="button"
          className="toolbar-btn"
          onClick={() => insertList('number')}
          title="Numbered List"
        >
          <i className="fas fa-list-ol"></i>
        </button>
        <button
          type="button"
          className="toolbar-btn"
          onClick={insertQuote}
          title="Quote"
        >
          <i className="fas fa-quote-left"></i>
        </button>
        <button
          type="button"
          className="toolbar-btn"
          onClick={insertCode}
          title="Code Block"
        >
          <i className="fas fa-terminal"></i>
        </button>
      </div>
    </div>
  );
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
          // Temporarily disabled to prevent infinite reload
          // hiddenField.dispatchEvent(new Event('input', { bubbles: true }));
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
            const listNode = $createListNode('bullet');
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
            const listNode = $createListNode('number');
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
      <div className="rich-text-editor-container">
        <RichTextToolbarPlugin />
        <div className="rich-text-editor-inner">
          <RichTextPlugin
            contentEditable={
              <ContentEditable
                className="rich-text-editor-content"
                style={{ outline: 'none' }}
              />
            }
            placeholder={
              <div className="rich-text-editor-placeholder">{placeholder}</div>
            }
            ErrorBoundary={LexicalErrorBoundary}
          />
        </div>
        <HistoryPlugin />
        <ListPlugin />
        <LinkPlugin />
        <CheckListPlugin />
        <TabIndentationPlugin />
        <SlashCommandsPlugin />
        {initialContent && <InitialContentPlugin initialContent={initialContent} />}
        {hiddenFieldId && <ContentSyncPlugin hiddenFieldId={hiddenFieldId} />}
      </div>
    </LexicalComposer>
  );
}
