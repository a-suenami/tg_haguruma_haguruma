import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

/**
 * Loading component that displays a Material Design progress spinner
 * @selector cog-loading
 * @standalone true
 */
@Component({
  selector: 'cog-loading',
  imports: [MatProgressSpinnerModule],
  templateUrl: './loading.component.html',
  styleUrl: './loading.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LoadingComponent {
  /**
   * Size of the spinner in pixels
   * @default 50
   */
  readonly size = input<number>(50);
}