import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'cog-detail-fragment',
  imports: [CommonModule],
  templateUrl: './detail-fragment.component.html',
  styleUrl: './detail-fragment.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DetailFragment {}
