import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { SnsItem } from '../sns-item/sns-item.component';
import { SnsItems } from './sns-items.component';

const meta: Meta<SnsItems> = {
  component: SnsItems,
  title: 'Core/Components/Social/SnsItems',
  decorators: [
    moduleMetadata({
      imports: [SnsItem],
    }),
  ],
};
export default meta;

type Story = StoryObj<SnsItems>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-sns-items>
          <a cog-sns-item [type]="'line'" href="https://line.me/example" target="_blank"></a>
          <a cog-sns-item [type]="'x'" href="https://x.com/example" target="_blank"></a>
          <a cog-sns-item [type]="'instagram'" href="https://instagram.com/example" target="_blank"></a>
          <a cog-sns-item [type]="'youtube'" href="https://youtube.com/@example" target="_blank"></a>
        </cog-sns-items>
      </div>
    `,
  }),
};
