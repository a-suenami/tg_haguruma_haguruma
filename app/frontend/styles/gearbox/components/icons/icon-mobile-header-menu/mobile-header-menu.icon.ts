import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-icon-mobile-header-menu',
  imports: [CommonModule],
  templateUrl: '../svg-files/icon_mobile-header-menu.svg',
  styleUrls: ['../styles/cog-icon.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MobileHeaderMenuIcon {}
