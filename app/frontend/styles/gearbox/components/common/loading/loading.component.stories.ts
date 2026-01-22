import type { Meta, StoryObj } from '@storybook/angular';

import { LoadingComponent } from './loading.component';

const meta: Meta<LoadingComponent> = {
  title: 'Core/Components/Common/Loading',
  component: LoadingComponent,
  tags: ['autodocs'],
  argTypes: {
    size: {
      control: { type: 'number', min: 20, max: 200, step: 10 },
      description: 'Size of the spinner in pixels',
      defaultValue: 50,
    },
  },
};

export default meta;
type Story = StoryObj<LoadingComponent>;

/**
 * Default loading spinner
 */
export const Default: Story = {
  args: {
    size: 50,
  },
  render: (args) => ({
    props: args,
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-primary-container); display: flex; align-items: center; justify-content: center; height: 200px;">
        <cog-loading style="--mat-progress-spinner-active-indicator-color: var(--gearbox-on-primary-container);" [size]="size"></cog-loading>
      </div>
    `,
  }),
};

/**
 * Small loading spinner
 */
export const Small: Story = {
  args: {
    size: 30,
  },
  render: (args) => ({
    props: args,
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-secondary-container); display: flex; align-items: center; justify-content: center; height: 200px;">
        <cog-loading style="--mat-progress-spinner-active-indicator-color: var(--gearbox-on-primary-container);" [size]="size"></cog-loading>
      </div>
    `,
  }),
};

/**
 * Large loading spinner
 */
export const Large: Story = {
  args: {
    size: 100,
  },
  render: (args) => ({
    props: args,
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-secondary-container); display: flex; align-items: center; justify-content: center; height: 300px;">
        <cog-loading style="--mat-progress-spinner-active-indicator-color: var(--gearbox-on-primary-container);" [size]="size"></cog-loading>
      </div>
    `,
  }),
};

/**
 * Multiple sizes comparison
 */
export const SizeComparison: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-secondary-container);">
        <div style="display: flex; gap: 2rem; align-items: center; justify-content: center;">
          <div style="display: flex; flex-direction: column; align-items: center; gap: 0.5rem;">
            <cog-loading style="--mat-progress-spinner-active-indicator-color: var(--gearbox-on-primary-container);" [size]="20"></cog-loading>
            <span>20px</span>
          </div>
          <div style="display: flex; flex-direction: column; align-items: center; gap: 0.5rem;">
            <cog-loading style="--mat-progress-spinner-active-indicator-color: var(--gearbox-on-primary-container);" [size]="30"></cog-loading>
            <span>30px</span>
          </div>
          <div style="display: flex; flex-direction: column; align-items: center; gap: 0.5rem;">
            <cog-loading style="--mat-progress-spinner-active-indicator-color: var(--gearbox-on-primary-container);" [size]="50"></cog-loading>
            <span>50px (default)</span>
          </div>
          <div style="display: flex; flex-direction: column; align-items: center; gap: 0.5rem;">
            <cog-loading style="--mat-progress-spinner-active-indicator-color: var(--gearbox-on-primary-container);" [size]="70"></cog-loading>
            <span>70px</span>
          </div>
          <div style="display: flex; flex-direction: column; align-items: center; gap: 0.5rem;">
            <cog-loading style="--mat-progress-spinner-active-indicator-color: var(--gearbox-on-primary-container);" [size]="100"></cog-loading>
            <span>100px</span>
          </div>
        </div>
      </div>
    `,
  }),
};

/**
 * Loading spinner in a card context
 */
export const InCardContext: Story = {
  args: {
    size: 40,
  },
  render: (args) => ({
    props: args,
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-secondary-container);">
        <div style="background: white; border-radius: 8px; padding: 2rem; box-shadow: 0 2px 8px rgba(0,0,0,0.1); max-width: 300px; margin: 0 auto;">
          <h3 style="margin-top: 0; margin-bottom: 1rem;">Loading Content</h3>
          <div style="display: flex; justify-content: center; padding: 2rem 0;">
            <cog-loading style="--mat-progress-spinner-active-indicator-color: var(--gearbox-on-primary-container);" [size]="size"></cog-loading>
          </div>
          <p style="text-align: center; color: #666; margin-bottom: 0;">Please wait while we fetch your data...</p>
        </div>
      </div>
    `,
  }),
};
