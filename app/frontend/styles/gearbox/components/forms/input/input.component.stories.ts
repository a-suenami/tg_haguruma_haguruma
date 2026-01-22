import { type Meta, type StoryObj } from '@storybook/angular';

import { InputComponent } from './input.component';

const meta: Meta<InputComponent> = {
  component: InputComponent,
  title: 'Core/Components/Forms/Input',
  tags: ['autodocs'],
};

export default meta;

type Story = StoryObj<InputComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 600px;">
        <div style="display: flex; flex-direction: column; gap: 1rem;">
          <input cog-input placeholder="Input text..." type="text" />
        </div>
      </div>
    `,
  }),
};

export const Invalid: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 600px;">
        <div style="display: flex; flex-direction: column; gap: 1rem;">
          <input cog-input placeholder="Input text..." type="text" class="invalid" value="Invalid value" />
        </div>
      </div>
    `,
  }),
};
