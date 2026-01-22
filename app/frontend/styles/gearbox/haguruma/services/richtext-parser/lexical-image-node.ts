import {
  DecoratorNode,
  DOMConversionMap,
  DOMConversionOutput,
  DOMExportOutput,
  LexicalNode,
  NodeKey,
  SerializedLexicalNode,
  Spread,
} from 'lexical';

export type SerializedImageNode = Spread<
  {
    src: string;
    altText?: string;
    width?: number;
    height?: number;
    maxWidth?: number;
    type: 'image';
    version: 1;
  },
  SerializedLexicalNode
>;

/**
 * Custom ImageNode for Lexical Editor
 * Handles image rendering in Lexical content
 */
export class ImageNode extends DecoratorNode<null> {
  __src: string;
  __altText?: string;
  __width?: number;
  __height?: number;
  __maxWidth?: number;

  constructor(
    src: string,
    altText?: string,
    width?: number,
    height?: number,
    maxWidth?: number,
    key?: NodeKey,
  ) {
    super(key);
    this.__src = src;
    this.__altText = altText;
    this.__width = width;
    this.__height = height;
    this.__maxWidth = maxWidth;
  }

  static override getType(): string {
    return 'image';
  }

  static override clone(node: ImageNode): ImageNode {
    return new ImageNode(
      node.__src,
      node.__altText,
      node.__width,
      node.__height,
      node.__maxWidth,
      node.__key,
    );
  }

  static override importJSON(serializedNode: SerializedImageNode): ImageNode {
    const { src, altText, width, height, maxWidth } = serializedNode;
    return $createImageNode(src, altText, width, height, maxWidth);
  }

  override exportJSON(): SerializedImageNode {
    return {
      src: this.__src,
      altText: this.__altText,
      width: this.__width,
      height: this.__height,
      maxWidth: this.__maxWidth,
      type: 'image',
      version: 1,
    };
  }

  override createDOM(): HTMLElement {
    const img = document.createElement('img');
    img.src = this.__src;
    if (this.__altText) {
      img.alt = this.__altText;
    }
    if (this.__width) {
      img.width = this.__width;
    }
    if (this.__height) {
      img.height = this.__height;
    }
    if (this.__maxWidth) {
      img.style.maxWidth = `${this.__maxWidth}px`;
    }
    img.style.display = 'block';
    img.style.margin = '1em 0';
    img.style.maxWidth = '100%';
    img.style.height = 'auto';
    return img;
  }

  override updateDOM(): false {
    return false;
  }

  static override importDOM(): DOMConversionMap | null {
    return {
      img: () => ({
        conversion: convertImageElement,
        priority: 0,
      }),
    };
  }

  override exportDOM(): DOMExportOutput {
    const element = document.createElement('img');
    element.src = this.__src;
    if (this.__altText) {
      element.alt = this.__altText;
    }
    if (this.__width) {
      element.width = this.__width;
    }
    if (this.__height) {
      element.height = this.__height;
    }
    if (this.__maxWidth) {
      element.style.maxWidth = `${this.__maxWidth}px`;
    }
    return { element };
  }

  override getTextContent(): string {
    return this.__altText ? `[Image: ${this.__altText}]` : '[Image]';
  }

  override decorate(): null {
    // For headless editor, we don't need to return a React component
    // The DOM representation is handled by createDOM
    return null;
  }
}

/**
 * Helper function to create an ImageNode
 */
export function $createImageNode(
  src: string,
  altText?: string,
  width?: number,
  height?: number,
  maxWidth?: number,
): ImageNode {
  return new ImageNode(src, altText, width, height, maxWidth);
}

/**
 * Helper function to check if a node is an ImageNode
 */
export function $isImageNode(
  node: LexicalNode | null | undefined,
): node is ImageNode {
  return node instanceof ImageNode;
}

/**
 * DOM conversion function for importing images
 */
function convertImageElement(domNode: Node): DOMConversionOutput | null {
  if (domNode instanceof HTMLImageElement) {
    const src = domNode.src;
    const alt = domNode.alt || undefined;
    const width = domNode.width || undefined;
    const height = domNode.height || undefined;
    const maxWidth = domNode.style.maxWidth
      ? parseInt(domNode.style.maxWidth, 10)
      : undefined;

    const node = $createImageNode(src, alt, width, height, maxWidth);
    return { node };
  }
  return null;
}
