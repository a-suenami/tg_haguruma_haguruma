import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'a[cog-menu-item]',
  imports: [CommonModule],
  templateUrl: './menu-item.component.html',
  styleUrl: './menu-item.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MenuItem {}
