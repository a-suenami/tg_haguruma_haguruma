import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { BlogDetailPage } from './blog-detail.page';

const meta: Meta<BlogDetailPage> = {
  title: 'Features/Blog/Pages/BlogDetail',
  component: BlogDetailPage,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [BlogDetailPage],
    }),
  ],
  parameters: {
    layout: 'fullscreen',
  },
};

export default meta;
type Story = StoryObj<BlogDetailPage>;

export const Default: Story = {
  render: () => ({
    template: `
      <cog-blog-detail></cog-blog-detail>
    `,
  }),
};
