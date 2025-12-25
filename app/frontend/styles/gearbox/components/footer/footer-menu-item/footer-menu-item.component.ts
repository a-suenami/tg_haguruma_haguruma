import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'a[cog-footer-menu-item]',
  imports: [CommonModule],
  templateUrl: './footer-menu-item.component.html',
  styleUrl: './footer-menu-item.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FooterMenuItem {}
