import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-menu-items',
  imports: [CommonModule],
  templateUrl: './menu-items.component.html',
  styleUrl: './menu-items.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MenuItemsComponent {}
