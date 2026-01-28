import type {
  DOMConversionMap,
  DOMConversionOutput,
  DOMExportOutput,
  EditorConfig,
  LexicalNode,
  NodeKey,
  Spread,
} from 'lexical';

import { DecoratorNode, $getNodeByKey } from 'lexical';
import { Suspense, useCallback, useRef, useState, useEffect } from 'react';
import { useLexicalNodeSelection } from '@lexical/react/useLexicalNodeSelection';
import { useLexicalComposerContext } from '@lexical/react/LexicalComposerContext';

export interface ImagePayload {
  altText: string;
  height?: number;
  key?: NodeKey;
  maxWidth?: number;
  src: string;
  width?: number;
}

function convertImageElement(domNode: Node): null | DOMConversionOutput {
  if (domNode instanceof HTMLImageElement) {
    const { alt: altText, src, width, height } = domNode;
    const node = $createImageNode({ altText, height, src, width });
    return { node };
  }
  return null;
}

export type SerializedImageNode = Spread<
  {
    altText: string;
    height?: number;
    maxWidth?: number;
    src: string;
    width?: number;
  },
  SerializedLexicalNode
>;

export class ImageNode extends DecoratorNode<JSX.Element> {
  __src: string;
  __altText: string;
  __width: 'inherit' | number;
  __height: 'inherit' | number;
  __maxWidth: number;

  static getType(): string {
    return 'image';
  }

  static clone(node: ImageNode): ImageNode {
    return new ImageNode(
      node.__src,
      node.__altText,
      node.__maxWidth,
      node.__width,
      node.__height,
      node.__key,
    );
  }

  static importJSON(serializedNode: SerializedImageNode): ImageNode {
    const { altText, height, width, maxWidth, src } = serializedNode;
    const node = $createImageNode({
      altText,
      height,
      maxWidth,
      src,
      width,
    });
    return node;
  }

  exportDOM(): DOMExportOutput {
    const element = document.createElement('img');
    element.setAttribute('src', this.__src);
    element.setAttribute('alt', this.__altText);
    element.setAttribute('width', this.__width.toString());
    element.setAttribute('height', this.__height.toString());
    return { element };
  }

  static importDOM(): DOMConversionMap | null {
    return {
      img: () => ({
        conversion: convertImageElement,
        priority: 0,
      }),
    };
  }

  constructor(
    src: string,
    altText: string,
    maxWidth: number,
    width?: 'inherit' | number,
    height?: 'inherit' | number,
    key?: NodeKey,
  ) {
    super(key);
    this.__src = src;
    this.__altText = altText;
    this.__maxWidth = maxWidth;
    this.__width = width || 'inherit';
    this.__height = height || 'inherit';
  }

  exportJSON(): SerializedImageNode {
    return {
      altText: this.getAltText(),
      height: this.__height === 'inherit' ? 0 : this.__height,
      maxWidth: this.__maxWidth,
      src: this.getSrc(),
      type: 'image',
      version: 1,
      width: this.__width === 'inherit' ? 0 : this.__width,
    };
  }

  setWidthAndHeight(
    width: 'inherit' | number,
    height: 'inherit' | number,
  ): void {
    const writable = this.getWritable();
    writable.__width = width;
    writable.__height = height;
  }

  createDOM(config: EditorConfig): HTMLElement {
    const span = document.createElement('span');
    const theme = config.theme;
    const className = theme.image;
    if (className !== undefined) {
      span.className = className;
    }
    return span;
  }

  updateDOM(): false {
    return false;
  }

  getSrc(): string {
    return this.__src;
  }

  getAltText(): string {
    return this.__altText;
  }

  decorate(): JSX.Element {
    return (
      <Suspense fallback={null}>
        <ImageComponent
          src={this.__src}
          altText={this.__altText}
          width={this.__width}
          height={this.__height}
          maxWidth={this.__maxWidth}
          nodeKey={this.getKey()}
        />
      </Suspense>
    );
  }
}

export function $createImageNode({
  altText,
  height,
  maxWidth = 500,
  src,
  width,
  key,
}: ImagePayload): ImageNode {
  return new ImageNode(src, altText, maxWidth, width, height, key);
}

export function $isImageNode(
  node: LexicalNode | null | undefined,
): node is ImageNode {
  return node instanceof ImageNode;
}

interface ImageComponentProps {
  altText: string;
  height: 'inherit' | number;
  maxWidth: number;
  nodeKey: NodeKey;
  src: string;
  width: 'inherit' | number;
}

function ImageComponent({
  src,
  altText,
  nodeKey,
  width,
  height,
  maxWidth,
}: ImageComponentProps): JSX.Element {
  const [editor] = useLexicalComposerContext();
  const [isSelected, setSelected, clearSelection] = useLexicalNodeSelection(nodeKey);
  const imageRef = useRef<HTMLImageElement>(null);
  const [isResizing, setIsResizing] = useState(false);

  // Track current dimensions during resize
  const [currentWidth, setCurrentWidth] = useState<number | 'inherit'>(width);
  const [currentHeight, setCurrentHeight] = useState<number | 'inherit'>(height);

  // Sync with props when not resizing
  useEffect(() => {
    if (!isResizing) {
      setCurrentWidth(width);
      setCurrentHeight(height);
    }
  }, [width, height, isResizing]);

  // Handle click to select
  const onClick = useCallback(
    (e: React.MouseEvent) => {
      e.stopPropagation();
      clearSelection();
      setSelected(true);
    },
    [clearSelection, setSelected],
  );

  // Handle resize
  const onResizeStart = useCallback(
    (e: React.MouseEvent, direction: string) => {
      e.preventDefault();
      e.stopPropagation();

      if (!imageRef.current) return;

      setIsResizing(true);
      const startX = e.clientX;
      const startWidth = imageRef.current.offsetWidth;
      const startHeight = imageRef.current.offsetHeight;
      const aspectRatio = startWidth / startHeight;

      // Determine resize direction multiplier
      const isLeft = direction.includes('w');
      const dirMultiplier = isLeft ? -1 : 1;

      // Track final dimensions in closure
      let finalWidth = startWidth;
      let finalHeight = startHeight;

      const onMouseMove = (moveEvent: MouseEvent) => {
        const deltaX = (moveEvent.clientX - startX) * dirMultiplier;
        let newWidth = startWidth + deltaX;

        // Constraints
        newWidth = Math.max(50, newWidth);
        newWidth = Math.min(newWidth, maxWidth);

        const newHeight = newWidth / aspectRatio;

        finalWidth = Math.round(newWidth);
        finalHeight = Math.round(newHeight);

        setCurrentWidth(finalWidth);
        setCurrentHeight(finalHeight);
      };

      const onMouseUp = () => {
        setIsResizing(false);
        document.removeEventListener('mousemove', onMouseMove);
        document.removeEventListener('mouseup', onMouseUp);

        // Update node with final dimensions
        editor.update(() => {
          const node = $getNodeByKey(nodeKey);
          if ($isImageNode(node)) {
            node.setWidthAndHeight(finalWidth, finalHeight);
          }
        });
      };

      document.addEventListener('mousemove', onMouseMove);
      document.addEventListener('mouseup', onMouseUp);
    },
    [editor, nodeKey, maxWidth],
  );

  // Click outside to deselect
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      if (isSelected && !target.closest('.image-wrapper')) {
        clearSelection();
      }
    };

    document.addEventListener('click', handleClickOutside);
    return () => document.removeEventListener('click', handleClickOutside);
  }, [isSelected, clearSelection]);

  return (
    <div
      className={`image-wrapper ${isSelected ? 'selected' : ''} ${isResizing ? 'resizing' : ''}`}
      onClick={onClick}
    >
      <img
        ref={imageRef}
        className="image-node"
        src={src}
        alt={altText}
        style={{
          width: currentWidth === 'inherit' ? undefined : currentWidth,
          height: currentHeight === 'inherit' ? undefined : currentHeight,
          maxWidth,
        }}
        draggable={false}
      />
      {isSelected && (
        <div className="image-resizer">
          <div
            className="resize-handle nw"
            onMouseDown={(e) => onResizeStart(e, 'nw')}
          />
          <div
            className="resize-handle ne"
            onMouseDown={(e) => onResizeStart(e, 'ne')}
          />
          <div
            className="resize-handle sw"
            onMouseDown={(e) => onResizeStart(e, 'sw')}
          />
          <div
            className="resize-handle se"
            onMouseDown={(e) => onResizeStart(e, 'se')}
          />
        </div>
      )}
    </div>
  );
}

import type { SerializedLexicalNode } from 'lexical';
