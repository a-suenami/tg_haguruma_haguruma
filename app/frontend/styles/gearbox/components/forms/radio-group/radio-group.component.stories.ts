import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { RadioComponent } from '../radio/radio.component';
import { RadioGroupComponent } from './radio-group.component';

const meta: Meta<RadioGroupComponent> = {
  title: 'Core/Components/Forms/Radio Group',
  component: RadioGroupComponent,
  decorators: [
    moduleMetadata({
      imports: [RadioGroupComponent, RadioComponent],
    }),
  ],
  tags: ['autodocs'],
  args: {
    defaultValue: 'option-1',
  },
  argTypes: {
    defaultValue: {
      control: 'text',
      description: 'Value selected when the group initializes',
    },
  },
};

export default meta;
type Story = StoryObj<RadioGroupComponent>;

const wrapper = (content: string) => `
  <div style="padding: 2rem; background-color: var(--gearbox-background);">
    ${content}
  </div>
`;

export const Default: Story = {
  render: (args) => ({
    props: {
      selected: args.defaultValue ?? null,
      handleChange: function (
        this: { selected: string | null },
        value: string | null,
      ) {
        this.selected = value;
      },
      config: args,
    },
    template: wrapper(`
      <cog-radio-group
        [defaultValue]="config.defaultValue"
        (changed)="handleChange($event)"
      >
        <cog-radio value="option-1" name="storybook-radio">Option 1</cog-radio>
        <cog-radio value="option-2" name="storybook-radio">Option 2</cog-radio>
        <cog-radio value="option-3" name="storybook-radio">Option 3</cog-radio>
      </cog-radio-group>
      <p style="margin-top: 1rem;">Selected: {{ selected || 'none' }}</p>
    `),
  }),
};

export const DisabledGroup: Story = {
  render: () => ({
    template: wrapper(`
      <cog-radio-group [disabled]="true">
        <cog-radio value="alpha" name="disabled-example">Alpha</cog-radio>
        <cog-radio value="beta" name="disabled-example">Beta</cog-radio>
        <cog-radio value="gamma" name="disabled-example">Gamma</cog-radio>
      </cog-radio-group>
    `),
  }),
};
