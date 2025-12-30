import type { Meta, StoryObj } from '@storybook/angular';

import { LandingSectionTitleComponent } from './landing-section-title.component';

const meta: Meta<LandingSectionTitleComponent> = {
  component: LandingSectionTitleComponent,
  title: 'Features/Landing/Components/LandingSectionTitle',
  parameters: {
    layout: 'centered',
  },
};
export default meta;

type Story = StoryObj<LandingSectionTitleComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="width: 600px; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section-title>
          <h2>Section Title</h2>
        </cog-landing-section-title>
      </div>
    `,
  }),
};

export const WithStyledHeading: Story = {
  render: () => ({
    template: `
      <div style="width: 600px; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section-title>
          <h1 style="font-size: 3rem; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; margin: 0;">
            Gradient Title
          </h1>
        </cog-landing-section-title>
      </div>
    `,
  }),
};

export const WithSubtitle: Story = {
  render: () => ({
    template: `
      <div style="width: 600px; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section-title>
          <h2 style="margin: 0;">Main Title</h2>
          <p style="color: #666; margin-top: 0.5rem;">This is a subtitle that provides additional context</p>
        </cog-landing-section-title>
      </div>
    `,
  }),
};

export const CenteredTitle: Story = {
  render: () => ({
    template: `
      <div style="width: 600px; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section-title>
          <div style="text-align: center;">
            <h2 style="font-size: 2.5rem; margin-bottom: 0.5rem;">Centered Title</h2>
            <div style="width: 60px; height: 4px; background: var(--gearbox-primary, #007bff); margin: 0 auto;"></div>
          </div>
        </cog-landing-section-title>
      </div>
    `,
  }),
};

export const WithIcon: Story = {
  render: () => ({
    template: `
      <div style="width: 600px; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section-title>
          <div style="display: flex; align-items: center; gap: 1rem;">
            <div style="width: 48px; height: 48px; background: var(--gearbox-primary, #007bff); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 24px;">
              ★
            </div>
            <h2 style="margin: 0;">Title with Icon</h2>
          </div>
        </cog-landing-section-title>
      </div>
    `,
  }),
};
