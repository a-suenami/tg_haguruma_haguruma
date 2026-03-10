import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'a[cog-header-menu-banner]',
  imports: [CommonModule],
  templateUrl: './header-menu-banner.component.html',
  styleUrl: './header-menu-banner.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class HeaderMenuBannerComponent {}
