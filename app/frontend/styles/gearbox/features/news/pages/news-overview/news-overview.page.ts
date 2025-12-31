import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

import {
  ListFragment,
  ListFragmentActions,
  ListFragmentContent,
  ListFragmentTitle,
  Tab,
  Tabs,
  TabsBar,
} from '@gearbox/ui';

import { NewsListComponent } from '../../components/news-list/news-list.component';
import { FeatureTitleImageComponent } from '../../../../shared/components/feature-title-image/feature-title-image.component';
import { PageFooterComponent } from '../../../../shared/layouts/page-footer/page-footer.component';
import { PageHeaderComponent } from '../../../../shared/layouts/page-header/page-header.component';

@Component({
  selector: 'cog-news-overview',
  imports: [
    CommonModule,
    NewsListComponent,
    PageHeaderComponent,
    PageFooterComponent,
    ListFragment,
    ListFragmentTitle,
    ListFragmentActions,
    ListFragmentContent,
    TabsBar,
    Tabs,
    Tab,
    FeatureTitleImageComponent,
  ],
  templateUrl: './news-overview.page.html',
  styleUrl: './news-overview.page.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class NewsOverviewPage {}
