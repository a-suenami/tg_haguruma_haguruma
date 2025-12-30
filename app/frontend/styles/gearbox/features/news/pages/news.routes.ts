import { Routes } from '@angular/router';

export const newsRoutes: Routes = [
  {
    path: '',
    redirectTo: 'list',
    pathMatch: 'full',
  },
  {
    path: 'list',
    loadComponent: () =>
      import('./news-overview/news-overview.page').then(
        (m) => m.NewsOverviewPage,
      ),
  },
  {
    path: 'detail/:id',
    loadComponent: () =>
      import('./news-detail/news-detail.page').then((m) => m.NewsDetailPage),
  },
];
