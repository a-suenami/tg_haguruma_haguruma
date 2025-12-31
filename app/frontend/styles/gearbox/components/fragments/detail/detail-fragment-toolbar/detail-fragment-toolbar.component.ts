import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'cog-detail-fragment-toolbar',
  imports: [CommonModule],
  templateUrl: './detail-fragment-toolbar.component.html',
  styleUrl: './detail-fragment-toolbar.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DetailFragmentToolbarComponent {}
