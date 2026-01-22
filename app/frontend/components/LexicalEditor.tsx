import { useState } from "react";
import { LexicalComposer } from "@lexical/react/LexicalComposer";
import { ContentEditable } from "@lexical/react/LexicalContentEditable";
import { RichTextPlugin } from "@lexical/react/LexicalRichTextPlugin";
import { LexicalErrorBoundary } from "@lexical/react/LexicalErrorBoundary";
import { HistoryPlugin } from "@lexical/react/LexicalHistoryPlugin";
import { ListPlugin } from "@lexical/react/LexicalListPlugin";
import { LinkPlugin } from "@lexical/react/LexicalLinkPlugin";
import { MarkdownShortcutPlugin } from "@lexical/react/LexicalMarkdownShortcutPlugin";

// Lexical nodes
import { HeadingNode, QuoteNode } from "@lexical/rich-text";
import { ListNode, ListItemNode } from "@lexical/list";
import { CodeNode } from "@lexical/code";
import { LinkNode, AutoLinkNode } from "@lexical/link";

import ToolbarPlugin from "./ToolbarPlugin";
import { ImageNode } from "./ImageNode";
import { VideoNode } from "./VideoNode";
import { AutoEmbedNode } from "./AutoEmbedNode";
import FileDragDropPlugin from "./FileDragDropPlugin";
import AutoEmbedPluginComponent from "./AutoEmbedPluginComponent";
import DraggableBlockPlugin from "./DraggableBlockPlugin";
import HiddenFieldSyncPlugin from "./HiddenFieldSyncPlugin";
import InitialContentPlugin from "./InitialContentPlugin";

// Markdown transformers
import {
  TRANSFORMERS,
} from "@lexical/markdown";

export interface LexicalEditorProps {
  initialContent?: string;
  placeholder?: string;
  hiddenFieldId?: string;
  editable?: boolean;
}

const theme = {
  text: {
    bold: "editor-text-bold",
    italic: "editor-text-italic",
    underline: "editor-text-underline",
    strikethrough: "editor-text-strikethrough",
    code: "editor-text-code",
  },
  heading: {
    h1: "editor-heading-h1",
    h2: "editor-heading-h2",
    h3: "editor-heading-h3",
    h4: "editor-heading-h4",
    h5: "editor-heading-h5",
    h6: "editor-heading-h6",
  },
  list: {
    nested: {
      listitem: "editor-nested-listitem",
    },
    ol: "editor-list-ol",
    ul: "editor-list-ul",
    listitem: "editor-listitem",
  },
  quote: "editor-quote",
  code: "editor-code",
  image: "editor-image",
  video: "editor-video",
  link: "editor-link",
};

const nodes = [
  HeadingNode,
  QuoteNode,
  CodeNode,
  ListNode,
  ListItemNode,
  LinkNode,
  AutoLinkNode,
  ImageNode,
  VideoNode,
  AutoEmbedNode,
];

export default function LexicalEditor({
  initialContent,
  placeholder = "Enter some rich text...",
  hiddenFieldId,
  editable = true,
}: LexicalEditorProps) {
  const [floatingAnchorElem, setFloatingAnchorElem] = useState<HTMLDivElement | null>(null);

  const onRef = (elem: HTMLDivElement | null) => {
    if (elem !== null) {
      setFloatingAnchorElem(elem);
    }
  };

  const initialConfig = {
    namespace: "RichTextEditor",
    theme,
    nodes,
    editable,
    onError: (error: Error) => {
      console.error(error);
    },
  };

  return (
    <div className={`editor-container${editable ? '' : ' editor-readonly'}`}>
      <LexicalComposer initialConfig={initialConfig}>
        {editable && <ToolbarPlugin />}
        <div className="editor-content" ref={onRef}>
          <RichTextPlugin
            contentEditable={
              <ContentEditable className="editor-input" />
            }
            placeholder={
              editable ? (
                <div className="editor-placeholder">
                  {placeholder}
                </div>
              ) : null
            }
            ErrorBoundary={LexicalErrorBoundary}
          />
          {editable && <HistoryPlugin />}
          <ListPlugin />
          <LinkPlugin />
          {editable && <MarkdownShortcutPlugin transformers={TRANSFORMERS} />}
          {editable && <FileDragDropPlugin />}
          {editable && <AutoEmbedPluginComponent />}
          {editable && floatingAnchorElem && (
            <DraggableBlockPlugin anchorElem={floatingAnchorElem} />
          )}
          {editable && hiddenFieldId && (
            <HiddenFieldSyncPlugin hiddenFieldId={hiddenFieldId} />
          )}
          {initialContent && (
            <InitialContentPlugin content={initialContent} />
          )}
        </div>
      </LexicalComposer>
    </div>
  );
}
