import type { Meta, StoryObj } from '@storybook/angular';
import { moduleMetadata } from '@storybook/angular';

import { NewsOverviewPage } from './news-overview.page';
import { NewsListComponent } from '../../components/news-list/news-list.component';
import { NewsItemComponent } from '../../components/news-item/news-item.component';

const meta: Meta<NewsOverviewPage> = {
  title: 'Features/News/Pages/NewsOverview',
  component: NewsOverviewPage,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [NewsOverviewPage, NewsListComponent, NewsItemComponent],
    }),
  ],
  parameters: {
    layout: 'fullscreen',
  },
};

export default meta;
type Story = StoryObj<NewsOverviewPage>;

export const Default: Story = {
  render: () => ({
    template: `
      <cog-news-overview></cog-news-overview>
    `,
  }),
};
