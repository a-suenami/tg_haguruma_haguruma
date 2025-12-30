import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-divider',
  imports: [CommonModule],
  templateUrl: './divider.component.html',
  styleUrl: './divider.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    role: 'separator',
    '[attr.aria-hidden]': 'true',
  },
})
export class DividerComponent {}
