import type { Meta, StoryObj } from '@storybook/angular';
import { moduleMetadata } from '@storybook/angular';

import { BlogItemComponent } from './blog-item.component';
import { dummyBlogItems } from '../blog-list/dummy-blog-items';

const meta: Meta<BlogItemComponent> = {
  title: 'Features/Blog/Components/BlogItem',
  component: BlogItemComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [BlogItemComponent],
    }),
  ],
  parameters: {
    layout: 'padded',
  },
};

export default meta;
type Story = StoryObj<BlogItemComponent>;

export const Default: Story = {
  args: {
    blog: dummyBlogItems[0],
  },
  render: (args) => ({
    props: args,
    template: `
      <div style="max-width: 600px; margin: 0 auto;">
        <cog-blog-item [blog]="blog"></cog-blog-item>
      </div>
    `,
  }),
};
