import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { Button } from '../../common/button/button.component';
import { FormFieldControlComponent } from '../form-field-control/form-field-control.component';
import { FormFieldLabelComponent } from '../form-field-label/form-field-label.component';
import { FormFieldComponent } from '../form-field/form-field.component';
import { FormGroupComponent } from '../form-group/form-group.component';
import { InputComponent } from '../input/input.component';
import { FormComponent } from './form.component';

const meta: Meta<FormComponent> = {
  component: FormComponent,
  title: 'Core/Components/Forms/Form',
  decorators: [
    moduleMetadata({
      imports: [
        Button,
        FormGroupComponent,
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

type Story = StoryObj<FormComponent>;

export const Default: Story = {
  render: () => {
    const submitState = {
      value: 'undefined',
    };

    return {
      props: {
        submitState,
        handleSubmit: (event: SubmitEvent) => {
          event.preventDefault();
          const formElement = event.target as HTMLFormElement;
          const formData = new FormData(formElement);
          const values = {
            first: formData.get('first') || 'empty',
            second: formData.get('second') || 'empty',
            third: formData.get('third') || 'empty',
            fourth: formData.get('fourth') || 'empty',
          };
          submitState.value = JSON.stringify(values, null, 2);
        },
      },
      template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 600px;">
        <h1>cog-form</h1>
        <form cog-form (submit)="handleSubmit($event)">
          <cog-form-group>
            <cog-form-field>
              <cog-form-field-label>CogFormFieldLabel</cog-form-field-label>
              <cog-form-field-control>
                <input cog-input placeholder="CogInput" name="first" />
              </cog-form-field-control>
            </cog-form-field>
            <cog-form-field>
              <cog-form-field-label>CogFormFieldLabel</cog-form-field-label>
              <cog-form-field-control>
                <input cog-input placeholder="CogInput" name="second" />
              </cog-form-field-control>
            </cog-form-field>
          </cog-form-group>

          <cog-form-group>
            <cog-form-field>
              <cog-form-field-label>CogFormFieldLabel</cog-form-field-label>
              <cog-form-field-control>
                <input cog-input placeholder="CogInput" name="third" />
              </cog-form-field-control>
            </cog-form-field>
            <cog-form-field>
              <cog-form-field-label>CogFormFieldLabel</cog-form-field-label>
              <cog-form-field-control>
                <input cog-input placeholder="CogInput" name="fourth" />
              </cog-form-field-control>
            </cog-form-field>
          </cog-form-group>

          <div style="margin-top: 1.5rem; display: flex; justify-content: flex-end;">
            <button cog-button filled primary type="submit" style="width: 100%;">
              Submit
            </button>
          </div>
        </form>

        <div style="margin-top: 1.5rem; background: white; border-radius: 0.5rem; padding: 1rem;">
          <h3>Submitted Form values</h3>
          <p style="white-space: pre-wrap;">{{ submitState.value }}</p>
        </div>
      </div>
    `,
    };
  },
};
