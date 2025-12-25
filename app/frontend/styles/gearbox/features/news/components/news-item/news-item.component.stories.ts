import type { Meta, StoryObj } from '@storybook/angular';
import { moduleMetadata } from '@storybook/angular';

import { NewsItemComponent } from './news-item.component';
import { DummyNewsOverview } from '../news-list/dummy-news-items';

const meta: Meta<NewsItemComponent> = {
  title: 'Features/News/Components/NewsItem',
  component: NewsItemComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [NewsItemComponent],
    }),
  ],
  argTypes: {
    news: {
      description: 'News item data',
    },
  },
};

export default meta;
type Story = StoryObj<NewsItemComponent>;

const sampleNews: DummyNewsOverview = {
  title: 'New Feature Release: Advanced Analytics Dashboard',
  date: '2024-01-15',
  category: {
    label: '更新履歴',
    type: 'updates',
  },
};

export const Default: Story = {
  args: {
    news: sampleNews,
  },
  render: (args) => ({
    props: args,
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-news-item [news]="news">
          <div style="padding: 1rem; border: 1px solid var(--gearbox-border-color); border-radius: 8px;">
            <h3 style="margin: 0 0 0.5rem 0;">{{ news.title }}</h3>
            <div style="display: flex; gap: 1rem; font-size: 0.875rem; color: var(--gearbox-text-secondary);">
              <span>{{ news.date }}</span>
              <span>{{ news.category.label }}</span>
            </div>
          </div>
        </cog-news-item>
      </div>
    `,
  }),
};
