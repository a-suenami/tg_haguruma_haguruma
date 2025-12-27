import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'cog-footer-menu',
  imports: [CommonModule],
  templateUrl: './footer-menu.component.html',
  styleUrl: './footer-menu.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FooterMenu {}
