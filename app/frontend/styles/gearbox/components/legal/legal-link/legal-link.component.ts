import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'a[cog-legal-link]',
  imports: [CommonModule],
  templateUrl: './legal-link.component.html',
  styleUrl: './legal-link.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LegalLink {}
