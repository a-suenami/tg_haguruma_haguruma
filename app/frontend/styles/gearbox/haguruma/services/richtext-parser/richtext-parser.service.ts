import { Injectable } from '@angular/core';
import { createHeadlessEditor } from '@lexical/headless';
import { $generateHtmlFromNodes, $generateNodesFromDOM } from '@lexical/html';
import { HeadingNode } from '@lexical/rich-text';
import {
  $getRoot,
  $insertNodes,
  ParagraphNode,
  SerializedEditorState,
  TextNode,
} from 'lexical';

import { ImageNode } from './lexical-image-node';

/**
 * Service for parsing Lexical rich text content using official Lexical packages
 */
@Injectable({
  providedIn: 'root',
})
export class RichtextParserService {
  /**
   * Creates a headless Lexical editor instance for parsing
   */
  private createEditor() {
    return createHeadlessEditor({
      namespace: 'RichTextParser',
      nodes: [HeadingNode, ParagraphNode, TextNode, ImageNode],
      onError: (error: Error) => {
        console.error('Lexical Editor Error:', error);
      },
    });
  }

  /**
   * Parses Lexical JSON to HTML using official Lexical packages
   * @param lexicalData - Lexical editor state as JSON string or object
   * @returns HTML string representation of the Lexical data
   */
  parseToHtml(lexicalData: string | Record<string, unknown>): string {
    try {
      const editor = this.createEditor();

      // Parse the JSON data
      const editorState =
        typeof lexicalData === 'string'
          ? editor.parseEditorState(lexicalData)
          : editor.parseEditorState(JSON.stringify(lexicalData));

      let htmlContent = '';

      // Set the editor state and generate HTML
      editor.setEditorState(editorState);
      editor.getEditorState().read(() => {
        htmlContent = $generateHtmlFromNodes(editor);
      });

      return htmlContent;
    } catch (error) {
      console.error('Error parsing Lexical rich text to HTML:', error);
      throw error;
    }
  }

  /**
   * Parses Lexical JSON to plain text
   * @param lexicalData - Lexical editor state as JSON string or object
   * @returns Plain text extracted from the Lexical data
   */
  parseToPlainText(lexicalData: string | Record<string, unknown>): string {
    try {
      const editor = this.createEditor();

      // Parse the JSON data
      const editorState =
        typeof lexicalData === 'string'
          ? editor.parseEditorState(lexicalData)
          : editor.parseEditorState(JSON.stringify(lexicalData));

      let plainText = '';

      // Set the editor state and extract text
      editor.setEditorState(editorState);
      editor.getEditorState().read(() => {
        const root = $getRoot();
        plainText = root.getTextContent();
      });

      return plainText;
    } catch (error) {
      console.error('Error parsing Lexical rich text to plain text:', error);
      return '';
    }
  }

  /**
   * Extracts metadata from Lexical rich text
   * @param lexicalData - Lexical editor state as JSON string or object
   * @returns Object containing extracted metadata
   */
  extractMetadata(lexicalData: string | Record<string, unknown>): {
    plainText: string;
    html: string;
    wordCount: number;
    characterCount: number;
    isEmpty: boolean;
  } {
    try {
      const plainText = this.parseToPlainText(lexicalData);
      const html = this.parseToHtml(lexicalData);

      // Calculate word and character counts
      const cleanText = plainText.trim();
      const words = cleanText.split(/\s+/).filter((word) => word.length > 0);

      return {
        plainText,
        html,
        wordCount: words.length,
        characterCount: cleanText.replace(/\s+/g, '').length,
        isEmpty: cleanText.length === 0,
      };
    } catch (error) {
      console.error('Error extracting metadata from Lexical rich text:', error);
      return {
        plainText: '',
        html: '',
        wordCount: 0,
        characterCount: 0,
        isEmpty: true,
      };
    }
  }

  /**
   * Validates if the provided data is valid Lexical JSON format
   * @param lexicalData - Data to validate
   * @returns True if valid Lexical format, false otherwise
   */
  isValidLexicalFormat(lexicalData: string | Record<string, unknown>): boolean {
    try {
      const editor = this.createEditor();

      // Try to parse the data with Lexical
      const editorState =
        typeof lexicalData === 'string'
          ? editor.parseEditorState(lexicalData)
          : editor.parseEditorState(JSON.stringify(lexicalData));

      // If parsing succeeds, it's valid
      return editorState !== null && editorState !== undefined;
    } catch {
      return false;
    }
  }

  /**
   * Converts HTML string to Lexical JSON format
   * @param html - HTML string to convert
   * @returns Lexical editor state as JSON object
   */
  htmlToLexical(html: string): SerializedEditorState | null {
    try {
      const editor = this.createEditor();

      // Parse HTML and generate Lexical nodes
      editor.update(() => {
        // Check if we're in a browser environment
        if (typeof DOMParser !== 'undefined') {
          // Browser environment
          const parser = new DOMParser();
          const dom = parser.parseFromString(html, 'text/html');

          // Generate Lexical nodes from DOM
          const nodes = $generateNodesFromDOM(editor, dom);

          // Clear the editor and insert new nodes
          $getRoot().clear();
          $insertNodes(nodes);
        } else {
          // Non-browser environment - just create a simple text node
          console.warn('DOMParser not available, creating text node instead');
          $getRoot().clear();
          // For server-side rendering, we'd need a library like jsdom
        }
      });

      // Get the editor state as JSON
      const editorState = editor.getEditorState();
      return editorState.toJSON();
    } catch (error) {
      console.error('Error converting HTML to Lexical:', error);
      return null;
    }
  }

  /**
   * Merges multiple Lexical JSON objects into one
   * @param lexicalDataArray - Array of Lexical editor states
   * @returns Merged Lexical editor state as JSON object
   */
  mergeLexicalContent(
    lexicalDataArray: Array<string | Record<string, unknown>>,
  ): SerializedEditorState | null {
    try {
      const editor = this.createEditor();

      // Process each Lexical data and combine
      editor.update(() => {
        $getRoot().clear();

        for (const lexicalData of lexicalDataArray) {
          const tempEditor = this.createEditor();

          const editorState =
            typeof lexicalData === 'string'
              ? tempEditor.parseEditorState(lexicalData)
              : tempEditor.parseEditorState(JSON.stringify(lexicalData));

          tempEditor.setEditorState(editorState);

          // Extract HTML and re-parse to merge
          tempEditor.getEditorState().read(() => {
            const html = $generateHtmlFromNodes(tempEditor);

            // Check if we're in a browser environment
            if (typeof DOMParser !== 'undefined') {
              const parser = new DOMParser();
              const dom = parser.parseFromString(html, 'text/html');
              const nodes = $generateNodesFromDOM(editor, dom);
              $insertNodes(nodes);
            } else {
              // In non-browser environment, we would need alternative approach
              console.warn('DOMParser not available for merging content');
            }
          });
        }
      });

      // Get the merged editor state as JSON
      const editorState = editor.getEditorState();
      return editorState.toJSON();
    } catch (error) {
      console.error('Error merging Lexical content:', error);
      return null;
    }
  }
}
