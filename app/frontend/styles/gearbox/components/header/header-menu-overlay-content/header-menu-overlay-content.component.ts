import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-header-menu-overlay-content',
  imports: [CommonModule],
  templateUrl: './header-menu-overlay-content.component.html',
  styleUrl: './header-menu-overlay-content.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class HeaderMenuOverlayContentComponent {}
