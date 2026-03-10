import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  ViewEncapsulation,
} from '@angular/core';
import { DomSanitizer } from '@angular/platform-browser';

import { RichtextParserService } from '../../services/richtext-parser/richtext-parser.service';

@Component({
  selector: 'cog-rich-content-viewer',
  imports: [CommonModule],
  templateUrl: './rich-content-viewer.component.html',
  styleUrl: './rich-content-viewer.component.scss',
  encapsulation: ViewEncapsulation.ShadowDom,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class RichContentViewerComponent {
  private readonly sanitizer = inject(DomSanitizer);
  private readonly richTextParser = inject(RichtextParserService);

  // Required Lexical JSON string input
  readonly lexicalJson = input.required<string>();

  // Parse the Lexical JSON to HTML
  readonly parsedHtml = computed(() => {
    try {
      const jsonData = JSON.parse(this.lexicalJson());
      return this.richTextParser.parseToHtml(jsonData);
    } catch (error) {
      console.error('Failed to parse Lexical JSON:', error);
      return '';
    }
  });

  // Metadata about the content
  readonly metadata = computed(() => {
    const jsonData = JSON.parse(this.lexicalJson());
    return this.richTextParser.extractMetadata(jsonData);
  });

  // Trusted content for rendering
  readonly trustedContent = computed(() => {
    if (!this.parsedHtml()) {
      return '';
    }
    return this.sanitizer.bypassSecurityTrustHtml(this.parsedHtml());
  });
}
