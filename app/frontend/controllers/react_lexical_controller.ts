import { Controller } from '@hotwired/stimulus';
import React from 'react';
import { createRoot } from 'react-dom/client';
import LexicalEditor from '../components/LexicalEditor';

export default class extends Controller {
  static values = { 
    initialContent: String,
    placeholder: String,
    hiddenFieldId: String
  };

  declare readonly initialContentValue: string;
  declare readonly placeholderValue: string;
  declare readonly hiddenFieldIdValue: string;

  private root: any;

  connect() {
    this.mountReactComponent();
  }

  disconnect() {
    if (this.root) {
      this.root.unmount();
    }
  }

  private mountReactComponent() {
    const props = {
      initialContent: this.initialContentValue || '',
      placeholder: this.placeholderValue || '記事の内容を入力してください...',
      hiddenFieldId: this.hiddenFieldIdValue || undefined,
    };

    this.root = createRoot(this.element);
    this.root.render(React.createElement(LexicalEditor, props));
  }
}