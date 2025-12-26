import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { FormFieldControlComponent } from '../form-field-control/form-field-control.component';
import { FormFieldLabelComponent } from '../form-field-label/form-field-label.component';
import { FormFieldComponent } from '../form-field/form-field.component';
import { FormComponent } from '../form/form.component';
import { InputComponent } from '../input/input.component';
import { FormGroupComponent } from './form-group.component';

const meta: Meta<FormGroupComponent> = {
  component: FormGroupComponent,
  title: 'Core/Components/Forms/FormGroup',
  decorators: [
    moduleMetadata({
      imports: [
        FormComponent,
        FormFieldComponent,
        FormFieldLabelComponent,
        FormFieldControlComponent,
        InputComponent,
      ],
    }),
  ],
  tags: ['autodocs'],
};

export default meta;

type Story = StoryObj<FormGroupComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 600px;">
        <form cog-form>
          <cog-form-group>
            <cog-form-field>
              <cog-form-field-label>First Name</cog-form-field-label>
              <cog-form-field-control>
                <input cog-input placeholder="Enter first name" />
              </cog-form-field-control>
            </cog-form-field>

            <cog-form-field>
              <cog-form-field-label>Last Name</cog-form-field-label>
              <cog-form-field-control>
                <input cog-input placeholder="Enter last name" />
              </cog-form-field-control>
            </cog-form-field>
          </cog-form-group>
        </form>
      </div>
    `,
  }),
};
