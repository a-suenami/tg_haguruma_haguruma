import type { Meta, StoryObj } from '@storybook/angular';

import { MenuItem } from './menu-item.component';

const meta: Meta<MenuItem> = {
  component: MenuItem,
  title: 'Core/Components/Menu/MenuItem',
};
export default meta;

type Story = StoryObj<MenuItem>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <a cog-menu-item href="#">Menu Item</a>
      </div>
    `,
  }),
};
