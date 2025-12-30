import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import {
  ChangeDetectionStrategy,
  Component,
  HostBinding,
  inject,
  input,
  OnInit,
  signal,
} from '@angular/core';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { firstValueFrom } from 'rxjs';

export type SnsType = 'line' | 'x' | 'instagram' | 'youtube';

@Component({
  selector: 'a[cog-sns-item]',
  imports: [CommonModule],
  templateUrl: './sns-item.component.html',
  styleUrl: './sns-item.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [HttpClient],
  host: {
    '[attr.aria-label]': 'ariaLabel',
  },
})
export class SnsItem implements OnInit {
  @HostBinding('class')
  get class(): string {
    return this.type();
  }

  readonly type = input.required<SnsType>();

  get ariaLabel(): string {
    const labels: Record<SnsType, string> = {
      line: 'Follow us on LINE',
      x: 'Follow us on X (formerly Twitter)',
      instagram: 'Follow us on Instagram',
      youtube: 'Subscribe to our YouTube channel',
    };
    return labels[this.type()];
  }

  private readonly http = inject(HttpClient);
  private readonly sanitizer = inject(DomSanitizer);

  get iconPath(): string {
    return `assets/social/${this.type()}.svg`;
  }

  get label() {
    return `${this.type()} Link Icon`;
  }

  icon = signal<SafeHtml | null>(null);

  async ngOnInit() {
    const text = await firstValueFrom(
      this.http.get(this.iconPath, { responseType: 'text' }),
    ).then((text) => {
      const removedXml = text.replace(
        '<?xml version="1.0" encoding="UTF-8"?>',
        '',
      );
      return this.sanitizer.bypassSecurityTrustHtml(removedXml);
    });
    this.icon.set(text);
  }
}
