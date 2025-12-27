import type { Meta, StoryObj } from '@storybook/angular';

import { CategoryLabel } from './category-label.component';

const meta: Meta<CategoryLabel> = {
  component: CategoryLabel,
  title: 'Core/Components/Labels/CategoryLabel',
  render: (args) => ({
    props: args,
    template: `
      <cog-category-label>Category</cog-category-label>
    `,
  }),
};
export default meta;

type Story = StoryObj<CategoryLabel>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; display: flex; gap: 1rem; flex-wrap: wrap;">
        <cog-category-label>News</cog-category-label>
        <cog-category-label>Blog</cog-category-label>
        <cog-category-label>Event</cog-category-label>
        <cog-category-label>Release</cog-category-label>
      </div>
    `,
  }),
};
