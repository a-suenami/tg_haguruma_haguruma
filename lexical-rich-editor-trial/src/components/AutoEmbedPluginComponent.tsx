import { LexicalAutoEmbedPlugin, AutoEmbedOption } from '@lexical/react/LexicalAutoEmbedPlugin';
import { EMBED_CONFIGS } from './EmbedConfigs';
import { useState } from 'react';

export default function AutoEmbedPluginComponent(): JSX.Element {
  const [embedModalOpen, setEmbedModalOpen] = useState(false);
  const [activeEmbedConfig, setActiveEmbedConfig] = useState<any>(null);

  return (
    <>
      <LexicalAutoEmbedPlugin
        embedConfigs={EMBED_CONFIGS}
        onOpenEmbedModalForConfig={(embedConfig) => {
          setActiveEmbedConfig(embedConfig);
          setEmbedModalOpen(true);
        }}
        getMenuOptions={(activeEmbedConfig, embedFn, dismissFn) => [
          new AutoEmbedOption('Embed', {
            onSelect: (targetNode) => {
              embedFn();
            },
          }),
          new AutoEmbedOption('Cancel', {
            onSelect: (targetNode) => {
              dismissFn();
            },
          }),
        ]}
        menuRenderFn={(anchorElementRef, { selectedIndex, selectOptionAndCleanUp, setHighlightedIndex }, options) => {
          if (options.length === 0) {
            return null;
          }

          return (
            <div 
              ref={anchorElementRef}
              className="auto-embed-menu"
            >
              {options.map((option, i) => (
                <div
                  key={option.key}
                  className={`auto-embed-menu-item ${i === selectedIndex ? 'selected' : ''}`}
                  onClick={() => {
                    setHighlightedIndex(i);
                    selectOptionAndCleanUp(option);
                  }}
                  onMouseEnter={() => {
                    setHighlightedIndex(i);
                  }}
                >
                  {option.title}
                </div>
              ))}
            </div>
          );
        }}
      />
      
      {embedModalOpen && (
        <EmbedModal
          embedConfig={activeEmbedConfig}
          onClose={() => {
            setEmbedModalOpen(false);
            setActiveEmbedConfig(null);
          }}
        />
      )}
    </>
  );
}

interface EmbedModalProps {
  embedConfig: any;
  onClose: () => void;
}

function EmbedModal({ embedConfig, onClose }: EmbedModalProps) {
  const [url, setUrl] = useState('');
  const [error, setError] = useState('');

  const handleEmbed = () => {
    if (!url.trim()) {
      setError('Please enter a URL');
      return;
    }

    const result = embedConfig.parseUrl(url);
    if (result) {
      embedConfig.insertNode(null, result); // Editor context handled in insertNode
      onClose();
    } else {
      setError(`Invalid ${embedConfig.type} URL`);
    }
  };

  const getPlaceholder = () => {
    switch (embedConfig?.type) {
      case 'youtube':
        return 'https://www.youtube.com/watch?v=...';
      case 'twitter':
        return 'https://twitter.com/user/status/...';
      default:
        return 'Enter URL...';
    }
  };

  return (
    <div className="embed-modal-overlay">
      <div className="embed-modal">
        <h3>Embed {embedConfig?.type?.toUpperCase()}</h3>
        
        <input
          type="text"
          value={url}
          onChange={(e) => {
            setUrl(e.target.value);
            setError('');
          }}
          placeholder={getPlaceholder()}
          className="embed-url-input"
          onKeyDown={(e) => {
            if (e.key === 'Enter') {
              handleEmbed();
            } else if (e.key === 'Escape') {
              onClose();
            }
          }}
          autoFocus
        />
        
        {error && <div className="embed-error">{error}</div>}
        
        <div className="embed-modal-actions">
          <button 
            onClick={handleEmbed}
            className="embed-button embed-button-primary"
          >
            Embed
          </button>
          <button 
            onClick={onClose}
            className="embed-button embed-button-secondary"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
  );
}