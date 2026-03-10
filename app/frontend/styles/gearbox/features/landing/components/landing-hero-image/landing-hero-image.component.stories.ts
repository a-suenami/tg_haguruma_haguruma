import type { Meta, StoryObj } from '@storybook/angular';

import { LandingHeroImageComponent } from './landing-hero-image.component';

const meta: Meta<LandingHeroImageComponent> = {
  component: LandingHeroImageComponent,
  title: 'Features/Landing/Components/LandingHeroImage',
  parameters: {
    layout: 'fullscreen',
  },
};
export default meta;

type Story = StoryObj<LandingHeroImageComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="width: 100vw;">
        <cog-landing-hero-image></cog-landing-hero-image>
      </div>
    `,
  }),
};
