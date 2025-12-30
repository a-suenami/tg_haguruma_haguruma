import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'cog-header-menu',
  imports: [CommonModule],
  templateUrl: './header-menu.component.html',
  styleUrl: './header-menu.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class HeaderMenu {}
