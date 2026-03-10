import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'cog-copyright',
  imports: [CommonModule],
  templateUrl: './copyright.component.html',
  styleUrl: './copyright.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Copyright {}
