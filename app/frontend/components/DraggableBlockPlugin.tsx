import { DraggableBlockPlugin_EXPERIMENTAL } from '@lexical/react/LexicalDraggableBlockPlugin';
import { useLexicalComposerContext } from '@lexical/react/LexicalComposerContext';
import {
  $createParagraphNode,
  $getNearestNodeFromDOMNode,
} from 'lexical';
import { useRef, useState } from 'react';
import { Grip } from "lucide-react";

function isOnMenu(element: HTMLElement): boolean {
  return (
    element.classList.contains('draggable-block-menu') ||
    element.classList.contains('draggable-block-handle') ||
    element.parentElement?.classList.contains('draggable-block-menu') ||
    false
  );
}

export default function DraggableBlockPlugin({
  anchorElem = document.body,
}: {
  anchorElem?: HTMLElement;
}): JSX.Element {
  const [editor] = useLexicalComposerContext();
  const menuRef = useRef<HTMLDivElement>(null);
  const targetLineRef = useRef<HTMLDivElement>(null);
  const [isDraggableElement, setIsDraggableElement] = useState<HTMLElement | null>(null);

  const insertBlock = (event: React.MouseEvent) => {
    if (!isDraggableElement) return;

    editor.update(() => {
      const node = $getNearestNodeFromDOMNode(isDraggableElement);
      if (node) {
        const newParagraph = $createParagraphNode();

        // Alt/Ctrl + Click で上に挿入、通常クリックで下に挿入
        if (event.altKey || event.ctrlKey) {
          node.insertBefore(newParagraph);
        } else {
          node.insertAfter(newParagraph);
        }

        // 新しい段落にフォーカスを移動
        newParagraph.select();
      }
    });
  };

  return (
    <DraggableBlockPlugin_EXPERIMENTAL
      anchorElem={anchorElem}
      menuRef={menuRef}
      targetLineRef={targetLineRef}
      menuComponent={
        <div
          ref={menuRef}
          className="draggable-block-menu"
          draggable="true"
        >
          <div
            className="draggable-block-handle"
            title="Drag to move block or click to add paragraph (Alt/Ctrl+Click to add above)"
            onClick={insertBlock}
            draggable="true"
          >
            <Grip absoluteStrokeWidth size={16} />
          </div>
        </div>
      }
      targetLineComponent={
        <div
          ref={targetLineRef}
          className="draggable-block-target-line"
        />
      }
      isOnMenu={isOnMenu}
      onElementChanged={setIsDraggableElement}
    />
  );
}
