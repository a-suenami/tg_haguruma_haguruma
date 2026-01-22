import type { EmbedConfig } from '@lexical/react/LexicalAutoEmbedPlugin';
import { $insertNodes, $isRangeSelection, $getSelection } from 'lexical';
import { $createAutoEmbedNode } from './AutoEmbedNode';

// YouTube URL patterns
const YOUTUBE_ID_REGEX = /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/i;

// Twitter URL patterns  
const TWITTER_ID_REGEX = /twitter\.com\/(?:#!\/)?(\w+)\/status(?:es)?\/(\d+)/i;

export const YouTubeEmbedConfig: EmbedConfig = {
  type: 'youtube',
  
  parseUrl: (text: string) => {
    const match = text.match(YOUTUBE_ID_REGEX);
    if (match && match[1]) {
      return {
        url: text,
        id: match[1],
      };
    }
    return null;
  },
  
  insertNode: (editor, result) => {
    editor.update(() => {
      const selection = $getSelection();
      if ($isRangeSelection(selection)) {
        const embedNode = $createAutoEmbedNode({
          type: 'youtube',
          url: result.url,
          id: result.id,
          data: result.data,
        });
        $insertNodes([embedNode]);
      }
    });
  },
};

export const TwitterEmbedConfig: EmbedConfig = {
  type: 'twitter',
  
  parseUrl: (text: string) => {
    const match = text.match(TWITTER_ID_REGEX);
    if (match && match[2]) {
      return {
        url: text,
        id: match[2], // Tweet ID
        data: {
          username: match[1], // Username
        },
      };
    }
    return null;
  },
  
  insertNode: (editor, result) => {
    editor.update(() => {
      const selection = $getSelection();
      if ($isRangeSelection(selection)) {
        const embedNode = $createAutoEmbedNode({
          type: 'twitter',
          url: result.url,
          id: result.id,
          data: result.data,
        });
        $insertNodes([embedNode]);
      }
    });
  },
};

// Export all configs
export const EMBED_CONFIGS = [
  YouTubeEmbedConfig,
  TwitterEmbedConfig,
];

// Helper function to get all supported embed types
export function getSupportedEmbedTypes(): string[] {
  return EMBED_CONFIGS.map(config => config.type);
}

// Type for synchronous embed match result
export interface EmbedMatchResult {
  url: string;
  id: string;
  data?: Record<string, unknown>;
}

export interface ParsedEmbed {
  config: EmbedConfig;
  result: EmbedMatchResult;
}

// Helper function to parse any supported URL
export function parseAnyEmbedUrl(text: string): ParsedEmbed | null {
  for (const config of EMBED_CONFIGS) {
    const result = config.parseUrl(text);
    // Our implementations are synchronous, so we can safely cast
    if (result && !(result instanceof Promise)) {
      return { config, result: result as EmbedMatchResult };
    }
  }
  return null;
}