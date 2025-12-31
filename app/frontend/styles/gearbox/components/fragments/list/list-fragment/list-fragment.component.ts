import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'cog-list-fragment',
  imports: [CommonModule],
  templateUrl: './list-fragment.component.html',
  styleUrl: './list-fragment.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ListFragment {}
