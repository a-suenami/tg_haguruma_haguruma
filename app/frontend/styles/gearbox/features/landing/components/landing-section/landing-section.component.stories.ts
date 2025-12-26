import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { LandingSectionContentComponent } from '../landing-section-content/landing-section-content.component';
import { LandingSectionTitleComponent } from '../landing-section-title/landing-section-title.component';
import { LandingSectionComponent } from './landing-section.component';

const meta: Meta<LandingSectionComponent> = {
  component: LandingSectionComponent,
  title: 'Features/Landing/Components/LandingSection',
  decorators: [
    moduleMetadata({
      imports: [
        LandingSectionComponent,
        LandingSectionTitleComponent,
        LandingSectionContentComponent,
      ],
    }),
  ],
  parameters: {
    layout: 'centered',
  },
};
export default meta;

type Story = StoryObj<LandingSectionComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="width: 100vw; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section>
          <cog-landing-section-title>
            <h2>Section Title</h2>
          </cog-landing-section-title>
          <cog-landing-section-content>
            <p>This is the main content area of the section.</p>
          </cog-landing-section-content>
        </cog-landing-section>
      </div>
    `,
  }),
};

export const ContentOnly: Story = {
  render: () => ({
    template: `
      <div style="width: 100vw; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section>
          <cog-landing-section-content>
            <div style="padding: 3rem 0;">
              <p style="font-size: 1.2rem; color: #666;">Section Content</p>
            </div>
          </cog-landing-section-content>
        </cog-landing-section>
      </div>
    `,
  }),
};
