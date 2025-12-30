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

import { BlogListComponent } from '../../components/blog-list/blog-list.component';
import { FeatureTitleImageComponent } from '../../../../shared/components/feature-title-image/feature-title-image.component';
import { PageFooterComponent } from '../../../../shared/layouts/page-footer/page-footer.component';
import { PageHeaderComponent } from '../../../../shared/layouts/page-header/page-header.component';

@Component({
  selector: 'cog-blog-overview',
  imports: [
    CommonModule,
    BlogListComponent,
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
  templateUrl: './blog-overview.page.html',
  styleUrl: './blog-overview.page.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BlogOverviewPage {}
