import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'cog-sns-items',
  imports: [CommonModule],
  templateUrl: './sns-items.component.html',
  styleUrl: './sns-items.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SnsItems {}
