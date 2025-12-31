import type { Meta, StoryObj } from '@storybook/angular';
import { moduleMetadata } from '@storybook/angular';

import { BlogOverviewPage } from './blog-overview.page';

const meta: Meta<BlogOverviewPage> = {
  title: 'Features/Blog/Pages/BlogOverview',
  component: BlogOverviewPage,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [BlogOverviewPage],
    }),
  ],
  parameters: {
    layout: 'fullscreen',
  },
};

export default meta;
type Story = StoryObj<BlogOverviewPage>;

export const Default: Story = {
  render: () => ({
    template: `
      <cog-blog-overview></cog-blog-overview>
    `,
  }),
};