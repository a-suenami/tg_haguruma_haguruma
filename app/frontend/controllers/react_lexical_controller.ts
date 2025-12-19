import { Controller } from '@hotwired/stimulus';
import React from 'react';
import { createRoot } from 'react-dom/client';
import LexicalEditor from '../components/LexicalEditor';

export default class extends Controller {
  static values = {
    initialContent: String,
    placeholder: String,
    hiddenFieldId: String,
    editable: { type: Boolean, default: true },
  };

  declare readonly initialContentValue: string;
  declare readonly placeholderValue: string;
  declare readonly hiddenFieldIdValue: string;
  declare readonly editableValue: boolean;

  private root: any = null;

  connect() {
    this.initializeReactLexicalEditor();
  }

  disconnect() {
    if (this.root) {
      this.root.unmount();
    }
  }

  private initializeReactLexicalEditor() {
    // Create React root and render the Lexical editor
    this.root = createRoot(this.element as HTMLElement);

    this.root.render(
      React.createElement(LexicalEditor, {
        initialContent: this.initialContentValue || '',
        placeholder: this.placeholderValue || '記事の内容を入力してください...',
        hiddenFieldId: this.hiddenFieldIdValue || undefined,
        editable: this.editableValue,
      })
    );
  }
}
