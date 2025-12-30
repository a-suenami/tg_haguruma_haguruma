import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-header-menu-overlay-footer',
  imports: [CommonModule],
  templateUrl: './header-menu-overlay-footer.component.html',
  styleUrl: './header-menu-overlay-footer.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class HeaderMenuOverlayFooterComponent {}
