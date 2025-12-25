import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { HeaderMenuBannerComponent } from './header-menu-banner.component';

const meta: Meta<HeaderMenuBannerComponent> = {
  component: HeaderMenuBannerComponent,
  title: 'Core/Components/Header/HeaderMenuBanner',
  decorators: [
    moduleMetadata({
      imports: [],
    }),
  ],
};
export default meta;

type Story = StoryObj<HeaderMenuBannerComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <a cog-header-menu-banner>
          <img src="assets/images/dummy-banner-1.png" alt="Header Menu Banner">
        </a>
      </div>
    `,
  }),
};
