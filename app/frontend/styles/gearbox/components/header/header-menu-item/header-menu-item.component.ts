import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'a[cog-header-menu-item]',
  imports: [CommonModule],
  template: '<ng-content></ng-content>',
  styleUrl: './header-menu-item.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    '[class.header-menu-item]': 'true',
  }
})
export class HeaderMenuItem {}
