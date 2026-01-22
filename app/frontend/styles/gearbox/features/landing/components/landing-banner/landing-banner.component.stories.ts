import type { Meta, StoryObj } from '@storybook/angular';

import { LandingBannerComponent } from './landing-banner.component';

const meta: Meta<LandingBannerComponent> = {
  component: LandingBannerComponent,
  title: 'Features/Landing/Components/LandingBanner',
  parameters: {
    layout: 'centered',
  },
};
export default meta;

type Story = StoryObj<LandingBannerComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="width: 400px; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <a href="#" cog-landing-banner
           [src]="'assets/images/dummy-banner-1.png'"
           [alt]="'Promotional banner for summer sale'">
        </a>
      </div>
    `,
  }),
};
