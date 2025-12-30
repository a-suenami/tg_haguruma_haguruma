import type { Meta, StoryObj } from '@storybook/angular';
import { moduleMetadata } from '@storybook/angular';

import { NewsDetailPage } from './news-detail.page';

const meta: Meta<NewsDetailPage> = {
  title: 'Features/News/Pages/NewsDetail',
  component: NewsDetailPage,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [NewsDetailPage],
    }),
  ],
  parameters: {
    layout: 'fullscreen',
  },
};

export default meta;
type Story = StoryObj<NewsDetailPage>;

export const Default: Story = {
  render: () => ({
    template: `
      <cog-news-detail></cog-news-detail>
    `,
  }),
};