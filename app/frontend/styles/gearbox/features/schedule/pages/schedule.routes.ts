import { Routes } from '@angular/router';

export const scheduleRoutes: Routes = [
  {
    path: '',
    redirectTo: 'list',
    pathMatch: 'full',
  },
  {
    path: 'list',
    loadComponent: () =>
      import('./schedule-overview/schedule-overview.page').then(
        (m) => m.ScheduleOverviewPage,
      ),
  },
  {
    path: 'detail/:id',
    loadComponent: () =>
      import('./schedule-detail/schedule-detail.page').then(
        (m) => m.ScheduleDetailPage,
      ),
  },
];