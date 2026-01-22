import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { CheckboxLinkComponent } from '../checkbox-link/checkbox-link.component';
import { CheckboxComponent } from './checkbox.component';

const meta: Meta<CheckboxComponent> = {
  component: CheckboxComponent,
  title: 'Core/Components/Forms/Checkbox',
  decorators: [
    moduleMetadata({
      imports: [CheckboxLinkComponent],
    }),
  ],
  tags: ['autodocs'],
};

export default meta;

type Story = StoryObj<CheckboxComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 600px;">
        <cog-checkbox id="terms" value="agree">
          <a cog-checkbox-link href="http://example.com">利用規約</a>に同意する
        </cog-checkbox>
      </div>
    `,
  }),
};

export const Checked: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 600px;">
        <cog-checkbox id="terms" value="agree" checked>
          <a cog-checkbox-link href="http://example.com">利用規約</a>に同意する
        </cog-checkbox>
      </div>
    `,
  }),
};

export const Disabled: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 600px;">
        <cog-checkbox id="terms" value="agree" disabled>
          <a cog-checkbox-link href="http://example.com">利用規約</a>に同意する
        </cog-checkbox>
      </div>
    `,
  }),
};
