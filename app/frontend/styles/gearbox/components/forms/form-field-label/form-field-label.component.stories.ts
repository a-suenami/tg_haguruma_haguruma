import { type Meta, type StoryObj } from '@storybook/angular';

import { FormFieldLabelComponent } from './form-field-label.component';

const meta: Meta<FormFieldLabelComponent> = {
  component: FormFieldLabelComponent,
  title: 'Core/Components/Forms/FormFieldLabel',
  tags: ['autodocs'],
};

export default meta;

type Story = StoryObj<FormFieldLabelComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 600px;">
        <cog-form-field-label>メールアドレス</cog-form-field-label>
      </div>
    `,
  }),
};
