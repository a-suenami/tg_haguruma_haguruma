import type {
  DOMConversionMap,
  DOMConversionOutput,
  DOMExportOutput,
  EditorConfig,
  LexicalNode,
  NodeKey,
  Spread,
} from 'lexical';

import { DecoratorNode } from 'lexical';
import { Suspense } from 'react';

export interface VideoPayload {
  src: string;
  width?: number;
  height?: number;
  key?: NodeKey;
}

function convertVideoElement(domNode: Node): null | DOMConversionOutput {
  if (domNode instanceof HTMLVideoElement) {
    const { src, width, height } = domNode;
    const node = $createVideoNode({ src, width, height });
    return { node };
  }
  return null;
}

export type SerializedVideoNode = Spread<
  {
    src: string;
    width?: number;
    height?: number;
  },
  SerializedLexicalNode
>;

export class VideoNode extends DecoratorNode<JSX.Element> {
  __src: string;
  __width: 'inherit' | number;
  __height: 'inherit' | number;

  static getType(): string {
    return 'video';
  }

  static clone(node: VideoNode): VideoNode {
    return new VideoNode(
      node.__src,
      node.__width,
      node.__height,
      node.__key,
    );
  }

  static importJSON(serializedNode: SerializedVideoNode): VideoNode {
    const { src, width, height } = serializedNode;
    const node = $createVideoNode({ src, width, height });
    return node;
  }

  exportDOM(): DOMExportOutput {
    const element = document.createElement('video');
    element.setAttribute('src', this.__src);
    element.setAttribute('controls', '');
    if (this.__width !== 'inherit') {
      element.setAttribute('width', this.__width.toString());
    }
    if (this.__height !== 'inherit') {
      element.setAttribute('height', this.__height.toString());
    }
    return { element };
  }

  static importDOM(): DOMConversionMap | null {
    return {
      video: (node: Node) => ({
        conversion: convertVideoElement,
        priority: 0,
      }),
    };
  }

  constructor(
    src: string,
    width?: 'inherit' | number,
    height?: 'inherit' | number,
    key?: NodeKey,
  ) {
    super(key);
    this.__src = src;
    this.__width = width || 'inherit';
    this.__height = height || 'inherit';
  }

  exportJSON(): SerializedVideoNode {
    return {
      src: this.getSrc(),
      type: 'video',
      version: 1,
      width: this.__width === 'inherit' ? undefined : this.__width,
      height: this.__height === 'inherit' ? undefined : this.__height,
    };
  }

  createDOM(config: EditorConfig): HTMLElement {
    const div = document.createElement('div');
    const theme = config.theme;
    const className = theme.video;
    if (className !== undefined) {
      div.className = className;
    }
    return div;
  }

  updateDOM(): false {
    return false;
  }

  getSrc(): string {
    return this.__src;
  }

  decorate(): JSX.Element {
    return (
      <Suspense fallback={null}>
        <VideoComponent
          src={this.__src}
          width={this.__width}
          height={this.__height}
          nodeKey={this.getKey()}
        />
      </Suspense>
    );
  }
}

export function $createVideoNode({
  src,
  width,
  height,
  key,
}: VideoPayload): VideoNode {
  return new VideoNode(src, width, height, key);
}

export function $isVideoNode(
  node: LexicalNode | null | undefined,
): node is VideoNode {
  return node instanceof VideoNode;
}

interface VideoComponentProps {
  src: string;
  width: 'inherit' | number;
  height: 'inherit' | number;
  nodeKey: NodeKey;
}

function VideoComponent({
  src,
  width,
  height,
  nodeKey,
}: VideoComponentProps): JSX.Element {
  return (
    <div className="video-wrapper">
      <video
        className="video-node"
        src={src}
        controls
        style={{
          width: width === 'inherit' ? '100%' : width,
          height: height === 'inherit' ? 'auto' : height,
          maxWidth: '100%',
        }}
      />
    </div>
  );
}

import type { SerializedLexicalNode } from 'lexical';