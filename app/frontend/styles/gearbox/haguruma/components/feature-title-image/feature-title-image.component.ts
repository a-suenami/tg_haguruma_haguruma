import { HttpClient } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, inject, input, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { firstValueFrom } from 'rxjs';

@Component({
  selector: 'cog-feature-title-image',
  imports: [CommonModule],
  templateUrl: './feature-title-image.component.html',
  styleUrl: './feature-title-image.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FeatureTitleImageComponent implements OnInit {
  private readonly http = inject(HttpClient);
  private readonly sanitizer = inject(DomSanitizer);

  readonly feature = input.required<'news' | 'blog' | 'ticket' | 'schedule'>();
  readonly titleSvg = signal<SafeHtml | null>(null);

  async ngOnInit() {
    const featureName = this.feature();
    if (!featureName) {
      return;
    }

    try {
      const imagePath = `assets/features/${featureName}/${featureName}-overview-title.svg`;
      const svgContent = await firstValueFrom(
        this.http.get(imagePath, { responseType: 'text' })
      );

      // Remove XML declaration if present
      const cleanedSvg = svgContent.replace(
        '<?xml version="1.0" encoding="UTF-8"?>',
        ''
      );

      const safeSvg = this.sanitizer.bypassSecurityTrustHtml(cleanedSvg);
      this.titleSvg.set(safeSvg);
    } catch (error) {
      console.error(`Failed to load SVG for feature: ${featureName}`, error);
    }
  }
}
