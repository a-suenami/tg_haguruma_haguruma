import { forwardRef } from '@angular/core';
import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { Tab, Tabs } from './tabs.component';

const meta: Meta<Tabs> = {
  component: Tabs,
  title: 'Core/Components/Navigation/Tabs',
  decorators: [
    moduleMetadata({
      imports: [forwardRef(() => Tab)],
    }),
  ],
};
export default meta;

type Story = StoryObj<Tabs>;

export const Primary: Story = {
  render: () => ({
    template: `
      <cog-tabs #tabs>
        <button cog-tab tab="tab1">Tab 1</button>
        <button cog-tab tab="tab2">Tab 2</button>
        <button cog-tab tab="tab3">Tab 3</button>
      </cog-tabs>
    `,
  }),
};
