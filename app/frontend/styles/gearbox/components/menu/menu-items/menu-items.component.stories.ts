import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { MenuItem } from '../menu-item/menu-item.component';
import { MenuItemsComponent } from './menu-items.component';

const meta: Meta<MenuItemsComponent> = {
  component: MenuItemsComponent,
  title: 'Core/Components/Menu/MenuItems',
  decorators: [
    moduleMetadata({
      imports: [MenuItem],
    }),
  ],
};
export default meta;

type Story = StoryObj<MenuItemsComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-menu-items>
          <a cog-menu-item href="#">Home</a>
          <a cog-menu-item href="#">About</a>
          <a cog-menu-item href="#">Services</a>
          <a cog-menu-item href="#">Contact</a>
        </cog-menu-items>
      </div>
    `,
  }),
};
