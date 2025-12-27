import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import {
  ChangeDetectionStrategy,
  Component,
  inject,
  resource,
} from '@angular/core';
import { firstValueFrom } from 'rxjs';

import {
  Button,
  CategoryLabel,
  DateLabel,
  DetailFragment,
  DetailFragmentActions,
  DetailFragmentContent,
  DetailFragmentHeaderComponent,
  DetailFragmentTitle,
  DetailFragmentToolbarComponent,
  LoadingComponent,
} from '@gearbox/ui';

import { RichContentViewerComponent } from '../../../../shared/components/rich-content-viewer/rich-content-viewer.component';
import { PageFooterComponent } from '../../../../shared/layouts/page-footer/page-footer.component';
import { PageHeaderComponent } from '../../../../shared/layouts/page-header/page-header.component';

@Component({
  selector: 'cog-news-detail',
  imports: [
    CommonModule,
    PageHeaderComponent,
    PageFooterComponent,
    Button,
    DetailFragment,
    DetailFragmentHeaderComponent,
    DetailFragmentToolbarComponent,
    DetailFragmentContent,
    DetailFragmentActions,
    CategoryLabel,
    DateLabel,
    DetailFragmentTitle,
    RichContentViewerComponent,
    LoadingComponent,
  ],
  templateUrl: './news-detail.page.html',
  styleUrl: './news-detail.page.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class NewsDetailPage {
  private readonly http = inject(HttpClient);

  // Function to fetch Lexical JSON content
  private async fetchLexicalContent(): Promise<string> {
    return firstValueFrom(
      this.http.get('/assets/dummies/lexical-richtext.json'),
    ).then((content) => JSON.stringify(content));
  }

  // Resource to fetch and manage Lexical JSON content
  readonly lexicalContent = resource({
    loader: () => this.fetchLexicalContent(),
  });
}
