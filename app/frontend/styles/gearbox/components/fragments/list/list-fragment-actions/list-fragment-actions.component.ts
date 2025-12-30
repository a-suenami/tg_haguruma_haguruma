import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'cog-list-fragment-actions',
  imports: [CommonModule],
  templateUrl: './list-fragment-actions.component.html',
  styleUrl: './list-fragment-actions.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ListFragmentActions {}
