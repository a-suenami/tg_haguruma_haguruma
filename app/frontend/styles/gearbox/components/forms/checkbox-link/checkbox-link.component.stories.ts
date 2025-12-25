import { type Meta, type StoryObj } from '@storybook/angular';

import { CheckboxLinkComponent } from './checkbox-link.component';

const meta: Meta<CheckboxLinkComponent> = {
  component: CheckboxLinkComponent,
  title: 'Core/Components/Forms/CheckboxLink',
  tags: ['autodocs'],
};

export default meta;

type Story = StoryObj<CheckboxLinkComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background); max-width: 600px;">
        <a cog-checkbox-link href="#">プライバシーポリシー</a>
      </div>
    `,
  }),
};
