import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { LegalLink } from '../legal-link/legal-link.component';
import { LegalLinks } from './legal-links.component';

const meta: Meta<LegalLinks> = {
  component: LegalLinks,
  decorators: [
    moduleMetadata({
      imports: [LegalLink],
    }),
  ],
  title: 'Core/Components/Legal/LegalLinks',
};
export default meta;

type Story = StoryObj<LegalLinks>;

export const Default: Story = {
  render: () => ({
    template: `
      <div style="padding: 2rem; background-color: var(--gearbox-background);">
        <cog-legal-links>
          <a cog-legal-link href="#">利用規約</a>
          <a cog-legal-link href="#">チケット規約</a>
          <a cog-legal-link href="#">プライバシー規約</a>
          <a cog-legal-link href="#">サイトポリシー</a>
          <a cog-legal-link href="#">特定商法取引法に基づく表記</a>
          <a cog-legal-link href="#">FAQ</a>
          <a cog-legal-link href="#">お問い合わせ</a>
        </cog-legal-links>
      </div>
    `,
  }),
};
