import type { Meta, StoryObj } from '@storybook/angular';

import { FormFieldErrorSlotComponent } from './form-field-error-slot.component';

const meta: Meta<FormFieldErrorSlotComponent> = {
  title: 'Core/Components/Forms/FormFieldErrorSlot',
  component: FormFieldErrorSlotComponent,
  tags: ['autodocs'],
};

export default meta;

type Story = StoryObj<FormFieldErrorSlotComponent>;

export const Default: Story = {
  render: (args) => ({
    props: args,
    template: `
      <div style="position: relative; padding: var(--gearbox-spacing-16); background: var(--gearbox-surface-container-low); height: 120px;">
        <cog-form-field-error-slot>
          <div style="color: var(--gearbox-danger);">Inline error message</div>
        </cog-form-field-error-slot>
      </div>
    `,
    imports: [FormFieldErrorSlotComponent],
  }),
};

