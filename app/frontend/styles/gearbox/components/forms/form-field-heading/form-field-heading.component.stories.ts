import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { FormFieldErrorComponent } from '../form-field-error/form-field-error.component';
import { FormFieldLabelComponent } from '../form-field-label/form-field-label.component';
import { FormFieldHeadingComponent } from './form-field-heading.component';

const meta: Meta<FormFieldHeadingComponent> = {
  title: 'Core/Components/Forms/FormFieldHeading',
  component: FormFieldHeadingComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [FormFieldLabelComponent, FormFieldErrorComponent],
    }),
  ],
};

export default meta;

type Story = StoryObj<FormFieldHeadingComponent>;

export const Default: Story = {
  render: (args) => ({
    props: args,
    template: `
      <div style="width: 100%; background: var(--gearbox-surface-dim); padding: var(--gearbox-spacing-16);">
        <cog-form-field-heading>
          <cog-form-field-label>Password</cog-form-field-label>
          <cog-form-field-error>Must include at least 8 characters.</cog-form-field-error>
        </cog-form-field-heading>
      </div>
    `,
    imports: [FormFieldHeadingComponent],
  }),
};
