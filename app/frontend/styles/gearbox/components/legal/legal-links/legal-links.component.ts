import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'cog-legal-links',
  imports: [CommonModule],
  templateUrl: './legal-links.component.html',
  styleUrl: './legal-links.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LegalLinks {}
