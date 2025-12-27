import { Routes } from '@angular/router';

export const blogRoutes: Routes = [
  {
    path: '',
    redirectTo: 'list',
    pathMatch: 'full',
  },
  {
    path: 'list',
    loadComponent: () =>
      import('./blog-overview/blog-overview.page').then(
        (m) => m.BlogOverviewPage,
      ),
  },
  {
    path: 'detail/:id',
    loadComponent: () =>
      import('./blog-detail/blog-detail.page').then((m) => m.BlogDetailPage),
  },
];