import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { HeaderMenuBannerComponent } from '../header-menu-banner/header-menu-banner.component';
import { HeaderMenuBannersComponent } from './header-menu-banners.component';

const meta: Meta<HeaderMenuBannersComponent> = {
  component: HeaderMenuBannersComponent,
  title: 'Core/Components/Header/HeaderMenuBanners',
  decorators: [
    moduleMetadata({
      imports: [HeaderMenuBannerComponent],
    }),
  ],
  parameters: {
    layout: 'fullscreen',
  },
};
export default meta;

type Story = StoryObj<HeaderMenuBannersComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-surface-scrim);">
        <cog-header-menu-banners>
          <a cog-header-menu-banner href="#">
            <img src="assets/images/dummy-banner-1.png" alt="Header Menu Banner 1">
          </a>
          <a cog-header-menu-banner href="#">
            <img src="assets/images/dummy-banner-2.png" alt="Header Menu Banner 2">
          </a>
          <a cog-header-menu-banner href="#">
            <img src="assets/images/dummy-banner-3.png" alt="Header Menu Banner 3">
          </a>
        </cog-header-menu-banners>
      </div>
    `,
  }),
};
