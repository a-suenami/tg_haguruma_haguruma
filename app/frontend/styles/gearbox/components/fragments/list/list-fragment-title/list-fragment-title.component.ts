import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'cog-list-fragment-title',
  imports: [CommonModule],
  templateUrl: './list-fragment-title.component.html',
  styleUrl: './list-fragment-title.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ListFragmentTitle {}
