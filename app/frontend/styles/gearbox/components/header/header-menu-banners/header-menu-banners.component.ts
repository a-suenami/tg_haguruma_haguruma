import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-header-menu-banners',
  imports: [CommonModule],
  templateUrl: './header-menu-banners.component.html',
  styleUrl: './header-menu-banners.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class HeaderMenuBannersComponent {}
