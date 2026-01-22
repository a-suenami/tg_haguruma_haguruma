import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  DestroyRef,
  effect,
  ElementRef,
  inject,
  signal,
  viewChild,
} from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { fromEvent } from 'rxjs';

@Component({
  selector: 'cog-tabs-bar',
  imports: [CommonModule],
  template: `
    <div class="inner" #inner>
      <ng-content></ng-content>
    </div>
  `,
  styleUrl: './tabs-bar.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    '[class.is-scrolling]': `this.isScrolling()`,
  },
})
export class TabsBar {
  private readonly el = viewChild<ElementRef<HTMLDivElement>>('inner');
  readonly isScrolling = signal(false);

  constructor() {
    const destroyRef = inject(DestroyRef);

    effect(() => {
      const innerElementRef = this.el();
      if (innerElementRef) {
        const innerElement = innerElementRef.nativeElement;

        fromEvent(innerElement, 'scroll')
          .pipe(takeUntilDestroyed(destroyRef))
          .subscribe(() => {
            this.isScrolling.set(true);
          });

        fromEvent(innerElement, 'scrollend')
          .pipe(takeUntilDestroyed(destroyRef))
          .subscribe(() => {
            this.isScrolling.set(false);
          });
      }
    });
  }
}
