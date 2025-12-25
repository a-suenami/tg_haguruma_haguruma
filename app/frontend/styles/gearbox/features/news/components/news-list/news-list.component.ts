import { CommonModule } from '@angular/common';
import {
  booleanAttribute,
  ChangeDetectionStrategy,
  Component,
  input,
  resource,
} from '@angular/core';
import { RouterLink } from '@angular/router';
import { delay, firstValueFrom, of } from 'rxjs';

import { Button } from '@gearbox/ui';

import { NewsItemComponent } from '../news-item/news-item.component';
import { dummyNewsItems } from './dummy-news-items';

@Component({
  selector: 'cog-news-list',
  imports: [CommonModule, NewsItemComponent, Button, RouterLink],
  templateUrl: './news-list.component.html',
  styleUrl: './news-list.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class NewsListComponent {
  readonly overview = input(false, { transform: booleanAttribute });

  newsResource = resource({
    loader: () => {
      return firstValueFrom(of(dummyNewsItems).pipe(delay(350)));
    },
  });
}
