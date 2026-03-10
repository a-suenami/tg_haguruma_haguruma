import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { InputComponent } from '../input/input.component';
import { FormFieldControlComponent } from './form-field-control.component';

const meta: Meta<FormFieldControlComponent> = {
  component: FormFieldControlComponent,
  title: 'Core/Components/Forms/FormFieldControl',
  decorators: [
    moduleMetadata({
      imports: [InputComponent],
    }),
  ],
  tags: ['autodocs'],
};

export default meta;

type Story = StoryObj<FormFieldControlComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 600px;">
        <cog-form-field-control>
          <input cog-input placeholder="Enter password" type="password" />
        </cog-form-field-control>
      </div>
    `,
  }),
};
