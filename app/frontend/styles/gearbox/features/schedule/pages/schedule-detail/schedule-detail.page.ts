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
  selector: 'cog-schedule-detail',
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
  templateUrl: './schedule-detail.page.html',
  styleUrl: './schedule-detail.page.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ScheduleDetailPage {
  private readonly http = inject(HttpClient);

  // Function to fetch Lexical JSON content
  private async fetchLexicalContent(): Promise<string> {
    // In a real application, this would fetch actual schedule event content from an API
    // For now, we're using the lexical-richtext.json file for demonstration purposes
    return firstValueFrom(
      this.http.get('/assets/dummies/lexical-richtext.json'),
    ).then((content) => JSON.stringify(content));
  }

  // Resource to fetch and manage Lexical JSON content
  readonly lexicalContent = resource({
    loader: () => this.fetchLexicalContent(),
  });
}
