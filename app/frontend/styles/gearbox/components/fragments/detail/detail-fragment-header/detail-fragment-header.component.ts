import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-detail-fragment-header',
  imports: [CommonModule],
  templateUrl: './detail-fragment-header.component.html',
  styleUrl: './detail-fragment-header.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DetailFragmentHeaderComponent {}
