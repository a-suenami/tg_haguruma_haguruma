import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { SelectControlComponent } from '../select-control/select-control.component';
import { SelectComponent } from './select.component';

const meta: Meta<SelectComponent> = {
  title: 'Core/Components/Forms/Select',
  component: SelectComponent,
  decorators: [
    moduleMetadata({
      imports: [SelectControlComponent, SelectComponent],
    }),
  ],
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<SelectComponent>;

const wrapper = (content: string) => `
  <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 320px;">
    ${content}
  </div>
`;

export const Default: Story = {
  render: () => ({
    template: wrapper(`
      <cog-select-control>
        <select cog-select name="storybook-select" id="storybook-select-id">
          <option value="">Choose an option</option>
          <option value="alpha">Alpha</option>
          <option value="beta">Beta</option>
          <option value="gamma">Gamma</option>
        </select>
      </cog-select-control>
    `),
  }),
};

export const Disabled: Story = {
  render: () => ({
    template: wrapper(`
      <cog-select-control>
        <select cog-select disabled>
          <option value="alpha">Alpha</option>
          <option value="beta">Beta</option>
          <option value="gamma">Gamma</option>
        </select>
      </cog-select-control>
    `),
  }),
};

export const Controlled: Story = {
  render: () => ({
    props: {
      value: 'beta',
    },
    template: wrapper(`
      <cog-select-control>
        <select cog-select [value]="value" (change)="value = $event.target.value">
          <option value="alpha">Alpha</option>
          <option value="beta">Beta</option>
          <option value="gamma">Gamma</option>
        </select>
      </cog-select-control>
      <p style="margin-top: 1rem;">Selected: {{ value }}</p>
    `),
  }),
};
