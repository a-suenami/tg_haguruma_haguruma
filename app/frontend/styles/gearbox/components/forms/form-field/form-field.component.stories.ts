import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { FormFieldControlComponent } from '../form-field-control/form-field-control.component';
import { FormFieldErrorSlotComponent } from '../form-field-error-slot/form-field-error-slot.component';
import { FormFieldErrorComponent } from '../form-field-error/form-field-error.component';
import { FormFieldHeadingComponent } from '../form-field-heading/form-field-heading.component';
import { FormFieldLabelComponent } from '../form-field-label/form-field-label.component';
import { FormFieldRequirementComponent } from '../form-field-requirement/form-field-requirement.component';
import { FormFieldRequirementsComponent } from '../form-field-requirements/form-field-requirements.component';
import { InputComponent } from '../input/input.component';
import { FormFieldComponent } from './form-field.component';

const meta: Meta<FormFieldComponent> = {
  component: FormFieldComponent,
  title: 'Core/Components/Forms/FormField',
  decorators: [
    moduleMetadata({
      imports: [
        FormFieldLabelComponent,
        FormFieldControlComponent,
        FormFieldRequirementsComponent,
        FormFieldRequirementComponent,
        FormFieldHeadingComponent,
        FormFieldErrorComponent,
        FormFieldErrorSlotComponent,
        InputComponent,
      ],
    }),
  ],
  tags: ['autodocs'],
};

export default meta;

type Story = StoryObj<FormFieldComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 600px;">
        <cog-form-field>
          <cog-form-field-label>Label</cog-form-field-label>
          <cog-form-field-control>
            <input cog-input placeholder="Enter text..." />
          </cog-form-field-control>
        </cog-form-field>
      </div>
    `,
  }),
};

export const WithRequirements: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 600px;">
        <cog-form-field>
          <cog-form-field-label>Password</cog-form-field-label>
          <cog-form-field-control>
            <input cog-input type="password" placeholder="Enter password ..." />
          </cog-form-field-control>

          <cog-form-field-requirements>
            <cog-form-field-requirement>Include at least 8 characters</cog-form-field-requirement>
            <cog-form-field-requirement [valid]="true">Include at least 8 characters</cog-form-field-requirement>
            <cog-form-field-requirement [dirty]="true" [valid]="false">Add at least one number</cog-form-field-requirement>
          </cog-form-field-requirements>
        </cog-form-field>
      </div>
    `,
  }),
};

export const WithError: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 600px;">
        <cog-form-field>
          <cog-form-field-heading>
            <cog-form-field-label>Password</cog-form-field-label>
          </cog-form-field-heading>

          <cog-form-field-control>
            <input cog-input type="text" placeholder="Enter password ..." class="invalid" value="Invalid value" />
          </cog-form-field-control>

          <cog-form-field-error-slot>
            <cog-form-field-error>Invalid input.</cog-form-field-error>
          </cog-form-field-error-slot>
        </cog-form-field>
      </div>
    `,
  }),
};
