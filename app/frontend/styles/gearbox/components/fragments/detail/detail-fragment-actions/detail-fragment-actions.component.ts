import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'cog-detail-fragment-actions',
  imports: [CommonModule],
  templateUrl: './detail-fragment-actions.component.html',
  styleUrl: './detail-fragment-actions.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DetailFragmentActions {}
