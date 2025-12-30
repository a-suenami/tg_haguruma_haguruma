import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { FooterMenuItem } from '../footer-menu-item/footer-menu-item.component';
import { FooterMenu } from './footer-menu.component';

const meta: Meta<FooterMenu> = {
  component: FooterMenu,
  title: 'Core/Components/Footer/FooterMenu',
  decorators: [
    moduleMetadata({
      imports: [FooterMenuItem],
    }),
  ],
};
export default meta;

type Story = StoryObj<FooterMenu>;

export const Default: Story = {
  args: {},
  render: () => ({
    template: `
      <cog-footer-menu>
        <a cog-footer-menu-item>TOP</a>
        <a cog-footer-menu-item>NEWS</a>
        <a cog-footer-menu-item>TICKET</a>
        <a cog-footer-menu-item>BLOG</a>
        <a cog-footer-menu-item>SCHEDULE</a>
        <a cog-footer-menu-item>MY PAGE</a>
      </cog-footer-menu>
    `,
  }),
};
