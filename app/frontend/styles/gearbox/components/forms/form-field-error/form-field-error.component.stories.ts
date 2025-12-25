import type { Meta, StoryObj } from '@storybook/angular';

import { FormFieldErrorComponent } from './form-field-error.component';

const meta: Meta<FormFieldErrorComponent> = {
  title: 'Core/Components/Forms/FormFieldError',
  component: FormFieldErrorComponent,
  tags: ['autodocs'],
};

export default meta;

type Story = StoryObj<FormFieldErrorComponent>;

export const Default: Story = {
  render: (args) => ({
    props: args,
    template: `<cog-form-field-error>Invalid input. Please correct the value.</cog-form-field-error>`,
  }),
};
