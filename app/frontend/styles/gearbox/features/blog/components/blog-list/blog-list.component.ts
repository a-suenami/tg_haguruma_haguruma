import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, resource } from '@angular/core';
import { RouterLink } from '@angular/router';
import { delay, firstValueFrom, of } from 'rxjs';

import { BlogItemComponent } from '../blog-item/blog-item.component';
import { dummyBlogItems } from './dummy-blog-items';
import { Button } from '@gearbox/ui';

@Component({
  selector: 'cog-blog-list',
  imports: [CommonModule, BlogItemComponent, Button, RouterLink],
  templateUrl: './blog-list.component.html',
  styleUrl: './blog-list.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BlogListComponent {
  // Using resource API to load blog items with simulated delay
  blogResource = resource({
    loader: () => {
      return firstValueFrom(of(dummyBlogItems).pipe(delay(350)));
    },
  });
}