import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { OnHeroImageFabIcon } from '../../icons/icon-on-hero-image-fab/on-hero-image-fab.icon';
import { FabButtonIcon } from './fab-button-icon/fab-button-icon.component';
import { FabButtonText } from './fab-button-text/fab-button-text.component';
import { FabButton } from './fab-button.component';

const meta: Meta<FabButton> = {
  component: FabButton,
  title: 'Core/Components/Common/FabButton',
  decorators: [
    moduleMetadata({
      imports: [OnHeroImageFabIcon, FabButtonIcon, FabButtonText],
    }),
  ],
  argTypes: {
    disabled: {
      control: { type: 'boolean' },
      description: 'Disabled state',
    },
  },
};
export default meta;

type Story = StoryObj<FabButton>;

export const DefaultPrimaryDirect: Story = {
  args: {
    disabled: false,
  },
  render: (args) => ({
    props: args,
    imports: [OnHeroImageFabIcon, FabButtonIcon],
    template: `
      <div style="display: flex; gap: 1rem;">
        <button cogFabButton primary [disabled]="disabled">
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
        </button>
        <button cogFabButton primary [disabled]="disabled">
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>FAB</cog-fab-button-text>
        </button>
      </div>
    `,
  }),
};

export const SecondaryDirect: Story = {
  args: {
    disabled: false,
  },
  render: (args) => ({
    props: args,
    imports: [OnHeroImageFabIcon, FabButtonIcon],
    template: `
      <div style="display: flex; gap: 1rem;">
        <button cogFabButton secondary [disabled]="disabled">
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
        </button>
        <button cogFabButton secondary [disabled]="disabled">
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>FAB</cog-fab-button-text>
        </button>
      </div>
    `,
  }),
};

export const PrimaryInverse: Story = {
  args: {
    disabled: false,
  },
  render: (args) => ({
    props: args,
    imports: [OnHeroImageFabIcon, FabButtonIcon],
    template: `
      <div style="display: flex; gap: 1rem;">
        <button cogFabButton primary inverse [disabled]="disabled">
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
        </button>

        <button cogFabButton primary inverse [disabled]="disabled">
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>FAB</cog-fab-button-text>
        </button>
      </div>
    `,
  }),
};

export const SecondaryInverse: Story = {
  args: {
    disabled: false,
  },
  render: (args) => ({
    props: args,
    imports: [OnHeroImageFabIcon, FabButtonIcon],
    template: `
      <div style="display: flex; gap: 1rem;">
        <button cogFabButton secondary inverse [disabled]="disabled">
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
        </button>

        <button cogFabButton secondary inverse [disabled]="disabled">
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>FAB</cog-fab-button-text>
        </button>
      </div>
    `,
  }),
};

export const AllSizes: Story = {
  render: () => ({
    imports: [OnHeroImageFabIcon, FabButtonIcon],
    template: `
      <div style="padding: 2rem; display: flex; gap: 2rem; align-items: center; flex-wrap: wrap;">
        <div style="display: flex; flex-direction: column; align-items: center; gap: 1rem;">
          <h3 style="margin: 0; font-size: 14px; color: #666;">Small</h3>
          <button cogFabButton primary small>
            <cog-fab-button-icon>
              <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
            </cog-fab-button-icon>
          </button>
        </div>
        <div style="display: flex; flex-direction: column; align-items: center; gap: 1rem;">
          <h3 style="margin: 0; font-size: 14px; color: #666;">Medium (Default)</h3>
          <button cogFabButton primary medium>
            <cog-fab-button-icon>
              <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
            </cog-fab-button-icon>
          </button>
        </div>
        <div style="display: flex; flex-direction: column; align-items: center; gap: 1rem;">
          <h3 style="margin: 0; font-size: 14px; color: #666;">Large</h3>
          <button cogFabButton primary large>
            <cog-fab-button-icon>
              <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
            </cog-fab-button-icon>
          </button>
        </div>
      </div>
    `,
  }),
};

export const WithText: Story = {
  render: () => ({
    imports: [OnHeroImageFabIcon, FabButtonIcon, FabButtonText],
    template: `
      <div style="padding: 2rem; display: flex; gap: 2rem; align-items: center;">
        <button cogFabButton primary>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>FAB</cog-fab-button-text>
        </button>
        <button cogFabButton secondary>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>Edit</cog-fab-button-text>
        </button>
      </div>
    `,
  }),
};

export const States: Story = {
  render: () => ({
    imports: [OnHeroImageFabIcon, FabButtonIcon, FabButtonText],
    template: `
      <div style="padding: 2rem; display: flex; gap: 2rem; align-items: center;">
        <button cogFabButton primary>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
        </button>
        <button cogFabButton primary disabled>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
        </button>
        <button cogFabButton primary>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>Enabled</cog-fab-button-text>
        </button>
        <button cogFabButton primary disabled>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>Disabled</cog-fab-button-text>
        </button>
      </div>

      <div style="padding: 2rem; display: flex; gap: 2rem; align-items: center;">
        <button cogFabButton primary inverse>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
        </button>
        <button cogFabButton primary inverse disabled>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
        </button>
        <button cogFabButton primary inverse>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>Enabled</cog-fab-button-text>
        </button>
        <button cogFabButton primary inverse disabled>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>Disabled</cog-fab-button-text>
        </button>
      </div>


      <div style="padding: 2rem; display: flex; gap: 2rem; align-items: center;">
        <button cogFabButton secondary>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
        </button>
        <button cogFabButton secondary disabled>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
        </button>
        <button cogFabButton secondary>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>Enabled</cog-fab-button-text>
        </button>
        <button cogFabButton secondary disabled>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>Disabled</cog-fab-button-text>
        </button>
      </div>


      <div style="padding: 2rem; display: flex; gap: 2rem; align-items: center;">
        <button cogFabButton secondary inverse>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
        </button>
        <button cogFabButton secondary inverse disabled>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
        </button>
        <button cogFabButton secondary inverse>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>Enabled</cog-fab-button-text>
        </button>
        <button cogFabButton secondary inverse disabled>
          <cog-fab-button-icon>
            <cog-icon-on-hero-image-fab></cog-icon-on-hero-image-fab>
          </cog-fab-button-icon>
          <cog-fab-button-text>Disabled</cog-fab-button-text>
        </button>
      </div>
    `,
  }),
};
