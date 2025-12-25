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

import { FeatureTitleImageComponent } from '../../../../shared/components/feature-title-image/feature-title-image.component';
import { PageFooterComponent } from '../../../../shared/layouts/page-footer/page-footer.component';
import { PageHeaderComponent } from '../../../../shared/layouts/page-header/page-header.component';
import { DatePickerComponent } from '../../components/date-picker/date-picker.component';
import { InlineCalendarComponent } from '../../components/inline-calendar/inline-calendar.component';
import { MonthlyScheduleListComponent } from '../../components/monthly-schedule-list/monthly-schedule-list.component';
import { ScheduleContainerComponent } from '../../components/schedule-container/schedule-container.component';

@Component({
  selector: 'cog-schedule-overview',
  imports: [
    CommonModule,
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
    ScheduleContainerComponent,
    MonthlyScheduleListComponent,
    InlineCalendarComponent,
    DatePickerComponent,
  ],
  templateUrl: './schedule-overview.page.html',
  styleUrl: './schedule-overview.page.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ScheduleOverviewPage {}
