import { moduleMetadata, type Meta, type StoryObj } from '@storybook/angular';

import { RichtextParserService } from '../../services/richtext-parser/richtext-parser.service';
import { RichContentViewerComponent } from './rich-content-viewer.component';

const meta: Meta<RichContentViewerComponent> = {
  title: 'Features/Shared/RichContentViewer',
  component: RichContentViewerComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [RichContentViewerComponent],
      providers: [RichtextParserService],
    }),
  ],
  parameters: {
    layout: 'padded',
  },
  argTypes: {
    lexicalJson: {
      control: 'text',
      description: 'Lexical JSON string to parse and display',
    },
  },
};

export default meta;
type Story = StoryObj<RichContentViewerComponent>;

export const Default: Story = {
  loaders: [
    async () => {
      const response = await fetch('/assets/dummies/lexical-richtext.json');
      const lexicalData = await response.json();
      return { lexicalJson: JSON.stringify(lexicalData) };
    },
  ],
  render: (_, { loaded: { lexicalJson } }) => ({
    props: { lexicalJson },
    template: `
      <div style="max-width: 800px; margin: 0 auto; padding: 2rem; background-color: #f5f5f5; border: 1px solid #e0e0e0; border-radius: 8px;">
        <h3 style="margin-bottom: 1rem; color: #666;">Lexical Rich Text from assets/dummies/lexical-richtext.json</h3>
        <code style="display: block; margin-bottom: 1rem; padding: 1rem; border-radius: 8px; background-color: #ffffff;">
          <cog-rich-content-viewer [lexicalJson]="lexicalJson"></cog-rich-content-viewer>
        </code>
      </div>
    `,
  }),
};
