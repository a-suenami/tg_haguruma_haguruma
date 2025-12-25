import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { FormFieldRequirementComponent } from '../form-field-requirement/form-field-requirement.component';
import { FormFieldRequirementsComponent } from './form-field-requirements.component';

const meta: Meta<FormFieldRequirementsComponent> = {
  title: 'Core/Components/Forms/FormFieldRequirements',
  component: FormFieldRequirementsComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [FormFieldRequirementComponent],
    }),
  ],
};

export default meta;

type Story = StoryObj<FormFieldRequirementsComponent>;

export const Default: Story = {
  render: (args) => ({
    props: args,
    template: `
      <cog-form-field-requirements>
        <cog-form-field-requirement>Include at least 8 characters</cog-form-field-requirement>
        <cog-form-field-requirement [valid]="true">Include at least 8 characters</cog-form-field-requirement>
        <cog-form-field-requirement [dirty]="true" [valid]="false">Add at least one number</cog-form-field-requirement>
      </cog-form-field-requirements>
    `,
  }),
};
