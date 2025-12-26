import type { Meta, StoryObj } from '@storybook/angular';

import { LandingSectionContentComponent } from './landing-section-content.component';

const meta: Meta<LandingSectionContentComponent> = {
  component: LandingSectionContentComponent,
  title: 'Features/Landing/Components/LandingSectionContent',
  parameters: {
    layout: 'centered',
  },
};
export default meta;

type Story = StoryObj<LandingSectionContentComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="width: 800px; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section-content>
          <p>This is the content area where you can place any type of content including text, images, videos, or other components.</p>
        </cog-landing-section-content>
      </div>
    `,
  }),
};

export const WithMultipleParagraphs: Story = {
  render: () => ({
    template: `
      <div style="width: 800px; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section-content>
          <p>First paragraph of content that introduces the topic and provides context for the reader.</p>
          <p>Second paragraph that goes into more detail about the subject matter, explaining key concepts and ideas.</p>
          <p>Third paragraph that concludes the section and provides a call to action or summary of the main points.</p>
        </cog-landing-section-content>
      </div>
    `,
  }),
};

export const WithList: Story = {
  render: () => ({
    template: `
      <div style="width: 800px; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section-content>
          <h3>Key Features:</h3>
          <ul>
            <li>Feature one with detailed description</li>
            <li>Feature two that provides additional value</li>
            <li>Feature three for enhanced functionality</li>
            <li>Feature four that sets us apart</li>
          </ul>
        </cog-landing-section-content>
      </div>
    `,
  }),
};

export const WithGrid: Story = {
  render: () => ({
    template: `
      <div style="width: 800px; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section-content>
          <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 2rem;">
            <div style="padding: 1.5rem; background: white; border-radius: 8px;">
              <h4>Column One</h4>
              <p>Content for the first column goes here.</p>
            </div>
            <div style="padding: 1.5rem; background: white; border-radius: 8px;">
              <h4>Column Two</h4>
              <p>Content for the second column goes here.</p>
            </div>
          </div>
        </cog-landing-section-content>
      </div>
    `,
  }),
};

export const WithImage: Story = {
  render: () => ({
    template: `
      <div style="width: 800px; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section-content>
          <div style="text-align: center;">
            <div style="width: 100%; height: 300px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 12px; display: flex; align-items: center; justify-content: center; color: white; font-size: 1.5rem; margin-bottom: 1rem;">
              Placeholder Image
            </div>
            <p>Caption text describing the image above.</p>
          </div>
        </cog-landing-section-content>
      </div>
    `,
  }),
};

export const WithCode: Story = {
  render: () => ({
    template: `
      <div style="width: 800px; padding: 2rem; background: var(--gearbox-background, #f5f5f5);">
        <cog-landing-section-content>
          <p>Here's how to use our component:</p>
          <pre style="background: #1e1e1e; color: #d4d4d4; padding: 1rem; border-radius: 4px; overflow-x: auto;">
<code>&lt;cog-landing-section&gt;
  &lt;cog-landing-section-content&gt;
    Your content here
  &lt;/cog-landing-section-content&gt;
&lt;/cog-landing-section&gt;</code>
          </pre>
        </cog-landing-section-content>
      </div>
    `,
  }),
};
