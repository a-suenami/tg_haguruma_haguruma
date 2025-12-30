import type { Meta, StoryObj } from '@storybook/angular';

import { FormFieldRequirementComponent } from './form-field-requirement.component';

const meta: Meta<FormFieldRequirementComponent> = {
  title: 'Core/Components/Forms/FormFieldRequirement',
  component: FormFieldRequirementComponent,
  tags: ['autodocs'],
};

export default meta;

type Story = StoryObj<FormFieldRequirementComponent>;

export const Default: Story = {
  render: (args) => ({
    props: args,
    template: `<cog-form-field-requirement>Include at least 8 characters</cog-form-field-requirement>`,
  }),
};

export const Untouched: Story = {
  render: (args) => ({
    props: args,
    template: `<cog-form-field-requirement>Untouched (default)</cog-form-field-requirement>`,
  }),
};

export const Valid: Story = {
  render: (args) => ({
    props: args,
    template: `<cog-form-field-requirement [valid]="true">Valid requirement</cog-form-field-requirement>`,
  }),
};

export const Invalid: Story = {
  render: (args) => ({
    props: args,
    template: `<cog-form-field-requirement [dirty]="true" [valid]="false">Invalid requirement</cog-form-field-requirement>`,
  }),
};
