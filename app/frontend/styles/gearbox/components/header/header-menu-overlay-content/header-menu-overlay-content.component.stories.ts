import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { HeaderMenuOverlayContentComponent } from './header-menu-overlay-content.component';

const meta: Meta<HeaderMenuOverlayContentComponent> = {
  component: HeaderMenuOverlayContentComponent,
  title: 'Core/Components/Header/HeaderMenuOverlayContent',
  decorators: [
    moduleMetadata({
      imports: [],
    }),
  ],
};
export default meta;

type Story = StoryObj<HeaderMenuOverlayContentComponent>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-header-menu-overlay-content>
          Header Menu Overlay Content
        </cog-header-menu-overlay-content>
      </div>
    `,
  }),
};
