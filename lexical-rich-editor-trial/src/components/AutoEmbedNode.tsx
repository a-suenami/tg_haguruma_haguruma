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

export interface AutoEmbedPayload {
  type: string;     // 'youtube', 'twitter', 'figma', etc.
  url: string;      // Original URL
  id: string;       // Extracted ID (video ID, tweet ID, etc.)
  data?: any;       // Additional data specific to embed type
  key?: NodeKey;
}

function convertEmbedElement(domNode: Node): null | DOMConversionOutput {
  if (domNode instanceof HTMLDivElement) {
    const embedType = domNode.getAttribute('data-embed-type');
    const embedUrl = domNode.getAttribute('data-embed-url');
    const embedId = domNode.getAttribute('data-embed-id');
    
    if (embedType && embedUrl && embedId) {
      const node = $createAutoEmbedNode({
        type: embedType,
        url: embedUrl,
        id: embedId,
      });
      return { node };
    }
  }
  return null;
}

export type SerializedAutoEmbedNode = Spread<
  {
    type: string;
    url: string;
    id: string;
    data?: any;
  },
  SerializedLexicalNode
>;

export class AutoEmbedNode extends DecoratorNode<JSX.Element> {
  __type: string;
  __url: string;
  __id: string;
  __data?: any;

  static getType(): string {
    return 'auto-embed';
  }

  static clone(node: AutoEmbedNode): AutoEmbedNode {
    return new AutoEmbedNode({
      type: node.__type,
      url: node.__url,
      id: node.__id,
      data: node.__data,
    }, node.__key);
  }

  static importJSON(serializedNode: SerializedAutoEmbedNode): AutoEmbedNode {
    const { type, url, id, data } = serializedNode;
    const node = $createAutoEmbedNode({ type, url, id, data });
    return node;
  }

  exportDOM(): DOMExportOutput {
    const div = document.createElement('div');
    div.setAttribute('data-embed-type', this.__type);
    div.setAttribute('data-embed-url', this.__url);
    div.setAttribute('data-embed-id', this.__id);
    
    // Embed specific content
    if (this.__type === 'youtube') {
      const iframe = document.createElement('iframe');
      iframe.src = `https://www.youtube.com/embed/${this.__id}`;
      iframe.frameBorder = '0';
      iframe.allowFullscreen = true;
      iframe.style.width = '100%';
      iframe.style.height = '315px';
      div.appendChild(iframe);
    }
    
    return { element: div };
  }

  static importDOM(): DOMConversionMap | null {
    return {
      div: (node: Node) => ({
        conversion: convertEmbedElement,
        priority: 1,
      }),
    };
  }

  constructor(payload: AutoEmbedPayload, key?: NodeKey) {
    super(key);
    this.__type = payload.type;
    this.__url = payload.url;
    this.__id = payload.id;
    this.__data = payload.data;
  }

  exportJSON(): SerializedAutoEmbedNode {
    return {
      type: 'auto-embed',
      version: 1,
      type: this.__type,
      url: this.__url,
      id: this.__id,
      data: this.__data,
    };
  }

  createDOM(config: EditorConfig): HTMLElement {
    const div = document.createElement('div');
    const theme = config.theme;
    const className = theme.embedBlock || 'auto-embed';
    if (className !== undefined) {
      div.className = className;
    }
    return div;
  }

  updateDOM(): false {
    return false;
  }

  getEmbedType(): string {
    return this.__type;
  }

  getUrl(): string {
    return this.__url;
  }

  getId(): string {
    return this.__id;
  }

  getData(): any {
    return this.__data;
  }

  decorate(): JSX.Element {
    return (
      <Suspense fallback={<div>Loading embed...</div>}>
        <AutoEmbedComponent
          type={this.__type}
          url={this.__url}
          id={this.__id}
          data={this.__data}
          nodeKey={this.getKey()}
        />
      </Suspense>
    );
  }
}

export function $createAutoEmbedNode(payload: AutoEmbedPayload): AutoEmbedNode {
  return new AutoEmbedNode(payload);
}

export function $isAutoEmbedNode(
  node: LexicalNode | null | undefined,
): node is AutoEmbedNode {
  return node instanceof AutoEmbedNode;
}

interface AutoEmbedComponentProps {
  type: string;
  url: string;
  id: string;
  data?: any;
  nodeKey: NodeKey;
}

function AutoEmbedComponent({ type, url, id, data, nodeKey }: AutoEmbedComponentProps): JSX.Element {
  const renderEmbed = () => {
    switch (type) {
      case 'youtube':
        return (
          <div className="youtube-embed-wrapper">
            <div className="youtube-embed-container">
              <iframe
                src={`https://www.youtube.com/embed/${id}`}
                frameBorder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                allowFullScreen={true}
                title={`YouTube video ${id}`}
                className="youtube-iframe"
              />
            </div>
            <div className="youtube-video-info">
              <span className="youtube-icon">📺</span>
              <span className="youtube-text">YouTube Video</span>
            </div>
          </div>
        );
        
      case 'twitter':
        return (
          <div className="twitter-embed-wrapper">
            <div className="twitter-embed-container">
              <iframe
                src={`https://platform.twitter.com/embed/Tweet.html?id=${id}`}
                frameBorder="0"
                scrolling="no"
                allowTransparency={true}
                title={`Twitter tweet ${id}`}
                className="twitter-iframe"
                style={{ width: '100%', height: '500px' }}
              />
            </div>
            <div className="twitter-embed-info">
              <span className="twitter-icon">🐦</span>
              <span className="twitter-text">Twitter Post</span>
            </div>
          </div>
        );
        
      default:
        return (
          <div className="generic-embed-wrapper">
            <div className="generic-embed-info">
              <span className="generic-icon">🔗</span>
              <span className="generic-text">{type.toUpperCase()} Embed</span>
              <a href={url} target="_blank" rel="noopener noreferrer" className="embed-link">
                Open Original
              </a>
            </div>
          </div>
        );
    }
  };

  return (
    <div className="auto-embed-container">
      {renderEmbed()}
    </div>
  );
}

import type { SerializedLexicalNode } from 'lexical';