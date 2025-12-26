import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'cog-detail-fragment-title',
  imports: [CommonModule],
  templateUrl: './detail-fragment-title.component.html',
  styleUrl: './detail-fragment-title.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DetailFragmentTitle {}
