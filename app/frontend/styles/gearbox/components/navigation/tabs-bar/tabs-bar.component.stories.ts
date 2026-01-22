import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { Tab, Tabs } from '../tabs/tabs.component';
import { TabsBar } from './tabs-bar.component';

const meta: Meta<TabsBar> = {
  component: TabsBar,
  title: 'Core/Components/Navigation/TabsBar',
  decorators: [
    moduleMetadata({
      imports: [Tab, Tabs],
    }),
  ],
  parameters: {
    docs: {
      description: {
        component: 'TabsBar is a component that displays a list of tabs.',
      },
    },
  },
};
export default meta;

type Story = StoryObj<TabsBar>;

export const Default: Story = {
  render: () => ({
    template: `
      <cog-tabs-bar>
        <cog-tabs>
          <button cog-tab tab="tab1">Tab 1</button>
          <button cog-tab tab="tab2">Tab 2</button>
          <button cog-tab tab="tab3">Tab 3</button>
          <button cog-tab tab="tab4">Tab 4</button>
          <button cog-tab tab="tab5">Tab 5</button>
          <button cog-tab tab="tab6">Tab 6</button>
          <button cog-tab tab="tab7">Tab 7</button>
          <button cog-tab tab="tab8">Tab 8</button>
          <button cog-tab tab="tab9">Tab 9</button>
          <button cog-tab tab="tab10">Tab 10</button>
          <button cog-tab tab="tab11">Tab 11</button>
        </cog-tabs>
      </cog-tabs-bar>
    `,
  }),
};
