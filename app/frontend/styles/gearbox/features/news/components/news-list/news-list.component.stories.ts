import type { Meta, StoryObj } from '@storybook/angular';

import { NewsListComponent } from './news-list.component';

const meta: Meta<NewsListComponent> = {
  title: 'Features/News/Components/NewsList',
  component: NewsListComponent,
  tags: ['autodocs'],
  argTypes: {},
};

export default meta;
type Story = StoryObj<NewsListComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-news-list></cog-news-list>
      </div>
    `,
  }),
};
