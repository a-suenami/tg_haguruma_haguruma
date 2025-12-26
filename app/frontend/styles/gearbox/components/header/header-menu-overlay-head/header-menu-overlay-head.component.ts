import { CommonModule } from '@angular/common';
import {
  booleanAttribute,
  ChangeDetectionStrategy,
  Component,
  input,
} from '@angular/core';

@Component({
  selector: 'cog-header-menu-overlay-head',
  imports: [CommonModule],
  templateUrl: './header-menu-overlay-head.component.html',
  styleUrl: './header-menu-overlay-head.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class HeaderMenuOverlayHeadComponent {
  noDivider = input(false, { transform: booleanAttribute });
}
