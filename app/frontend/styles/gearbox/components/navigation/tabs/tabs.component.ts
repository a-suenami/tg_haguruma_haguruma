import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  contentChildren,
  effect,
  forwardRef,
  HostListener,
  inject,
  InjectionToken,
  input,
  output,
  signal,
} from '@angular/core';

export const COG_TABS = new InjectionToken<Tabs>('COG_TABS');

@Component({
  selector: 'cog-tabs',
  imports: [CommonModule],
  template: `<ng-content></ng-content>`,
  styleUrl: './tabs.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [
    {
      provide: COG_TABS,
      useExisting: Tabs,
    },
  ],
})
export class Tabs {
  readonly currentTab = signal<string>('');

  readonly tabDidChange = output<string>();

  private readonly tabButtons = contentChildren(
    forwardRef(() => Tab),
    { descendants: true },
  );

  selectTab(tab: string) {
    this.currentTab.set(tab);
  }

  constructor() {
    const tabButtonsEffectRef = effect(() => {
      if (this.tabButtons().length && this.tabButtons()[0]) {
        this.currentTab.set(this.tabButtons()[0].tab());
      } else {
        throw new Error('No tab buttons found');
      }
      tabButtonsEffectRef.destroy();
    });
  }
}

@Component({
  selector: 'button[cog-tab]',
  imports: [CommonModule],
  template: `
    <div class="text">
      <ng-content></ng-content>
    </div>
    <div class="current-line"></div>
  `,
  styleUrl: './tab.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    '[class.active]': 'active()',
  },
})
export class Tab {
  @HostListener('click')
  handleHostClicked() {
    if (this.tabs) {
      this.tabs.selectTab(this.tab());
    }
  }

  private readonly tabs = inject(COG_TABS, { optional: true });

  readonly tab = input.required<string>();
  readonly active = signal(false);

  constructor() {
    effect(() => {
      if (this.tabs) {
        this.active.set(this.tabs.currentTab() === this.tab());
      }
    });
  }
}
