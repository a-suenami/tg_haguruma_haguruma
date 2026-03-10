import type { Meta, StoryObj } from '@storybook/angular';

import { RadioComponent } from './radio.component';

const meta: Meta<RadioComponent> = {
  title: 'Core/Components/Forms/Radio',
  component: RadioComponent,
  tags: ['autodocs'],
  argTypes: {
    value: {
      control: 'text',
      description: 'Value submitted when the radio is selected',
    },
    name: {
      control: 'text',
      description: 'Optional field name when used standalone',
    },
  },
};

export default meta;
type Story = StoryObj<RadioComponent>;

const wrapper = (content: string) => `
  <div style="padding: 2rem; background-color: var(--gearbox-background);">
    ${content}
  </div>
`;

export const Playground: Story = {
  render: (args) => ({
    props: args,
    template: wrapper(`
      <cog-radio [value]="value" [name]="name">
        Radio label
      </cog-radio>
    `),
  }),
};
