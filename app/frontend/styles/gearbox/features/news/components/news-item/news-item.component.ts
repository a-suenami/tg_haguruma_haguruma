import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';

import { DummyNewsOverview } from '../news-list/dummy-news-items';
import { CategoryLabel, DateLabel } from '@gearbox/ui';

@Component({
  selector: 'cog-news-item',
  imports: [
    CommonModule,
    CategoryLabel,
    DateLabel
  ],
  templateUrl: './news-item.component.html',
  styleUrl: './news-item.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class NewsItemComponent {
  news = input.required<DummyNewsOverview>();
}
