import type { Meta, StoryObj } from '@storybook/angular';

import { FooterMenuItem } from './footer-menu-item.component';

const meta: Meta<FooterMenuItem> = {
  component: FooterMenuItem,
  title: 'Core/Components/Footer/FooterMenuItem',
};
export default meta;

type Story = StoryObj<FooterMenuItem>;

export const Primary: Story = {
  args: {},
  render: () => ({
    template: `
      <a cog-footer-menu-item>Footer Menu Item</a>
    `,
  }),
};
