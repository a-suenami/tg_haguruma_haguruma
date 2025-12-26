import type { Meta, StoryObj } from '@storybook/angular';
import { moduleMetadata } from '@storybook/angular';

import { BlogListComponent } from './blog-list.component';
import { BlogItemComponent } from '../blog-item/blog-item.component';

const meta: Meta<BlogListComponent> = {
  title: 'Features/Blog/Components/BlogList',
  component: BlogListComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [BlogListComponent, BlogItemComponent],
    }),
  ],
  parameters: {
    layout: 'padded',
  },
};

export default meta;
type Story = StoryObj<BlogListComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="max-width: 1200px; margin: 0 auto;">
        <cog-blog-list></cog-blog-list>
      </div>
    `,
  }),
};