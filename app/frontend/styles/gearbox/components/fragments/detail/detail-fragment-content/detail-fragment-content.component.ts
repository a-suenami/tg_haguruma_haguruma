import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'cog-detail-fragment-content',
  imports: [CommonModule],
  templateUrl: './detail-fragment-content.component.html',
  styleUrl: './detail-fragment-content.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DetailFragmentContent {}
