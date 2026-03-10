import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-header-menu-overlay-actions',
  imports: [CommonModule],
  templateUrl: './header-menu-overlay-actions.component.html',
  styleUrl: './header-menu-overlay-actions.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class HeaderMenuOverlayActions {}
