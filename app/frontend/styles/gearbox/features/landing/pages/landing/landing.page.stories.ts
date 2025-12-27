import { type Meta, type StoryObj } from '@storybook/angular';

import { LandingPage } from './landing.page';

const meta: Meta<LandingPage> = {
  component: LandingPage,
  title: 'Features/Landing/LandingPage',
  parameters: {
    layout: 'fullscreen',
  },
};
export default meta;

type Story = StoryObj<LandingPage>;

export const Primary: Story = {
  render: () => ({
    template: `
      <cog-landing-page></cog-landing-page>
    `,
  }),
};
