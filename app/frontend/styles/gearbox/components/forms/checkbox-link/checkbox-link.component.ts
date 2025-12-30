import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  HostListener,
} from '@angular/core';

@Component({
  selector: 'a[cog-checkbox-link]',
  imports: [CommonModule],
  templateUrl: './checkbox-link.component.html',
  styleUrl: './checkbox-link.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    target: '_blank',
    rel: 'noopener noreferrer',
  },
})
export class CheckboxLinkComponent {
  @HostListener('click', ['$event'])
  handleClick(event: Event) {
    event.stopPropagation();
  }
}
