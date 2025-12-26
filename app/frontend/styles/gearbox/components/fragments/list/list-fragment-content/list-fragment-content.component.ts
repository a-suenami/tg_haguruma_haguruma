import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'cog-list-fragment-content',
  imports: [CommonModule],
  templateUrl: './list-fragment-content.component.html',
  styleUrl: './list-fragment-content.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ListFragmentContent {}
