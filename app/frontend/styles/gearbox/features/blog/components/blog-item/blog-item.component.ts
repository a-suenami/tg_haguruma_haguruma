import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { CategoryLabel } from '@gearbox/ui';

import { DummyBlogOverview } from '../blog-list/dummy-blog-items';

@Component({
  selector: 'cog-blog-item',
  imports: [
    CommonModule,
    CategoryLabel
  ],
  templateUrl: './blog-item.component.html',
  styleUrl: './blog-item.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BlogItemComponent {
  blog = input.required<DummyBlogOverview>();
}
