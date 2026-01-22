import { useEffect, useRef, useCallback, useState } from 'react';
import { useLexicalComposerContext } from '@lexical/react/LexicalComposerContext';
import { OnChangePlugin } from '@lexical/react/LexicalOnChangePlugin';
import { $generateHtmlFromNodes } from '@lexical/html';
import type { EditorState, LexicalEditor } from 'lexical';

export type AutosaveStatus = 'idle' | 'saving' | 'saved' | 'error';

interface AutosavePluginProps {
  autosaveUrl: string;
  fieldName: string;
  debounceMs?: number;
  onStatusChange?: (status: AutosaveStatus, savedAt?: string) => void;
}

export default function AutosavePlugin({
  autosaveUrl,
  fieldName,
  debounceMs = 2000,
  onStatusChange,
}: AutosavePluginProps): JSX.Element {
  const [editor] = useLexicalComposerContext();
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const lastSavedContentRef = useRef<string>('');
  const [status, setStatus] = useState<AutosaveStatus>('idle');

  const updateStatus = useCallback((newStatus: AutosaveStatus, savedAt?: string) => {
    setStatus(newStatus);
    onStatusChange?.(newStatus, savedAt);
  }, [onStatusChange]);

  const saveContent = useCallback(async (html: string) => {
    // Skip if content hasn't changed
    if (html === lastSavedContentRef.current) {
      return;
    }

    updateStatus('saving');

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

      const formData = new FormData();
      formData.append(`fields[${fieldName}]`, html);

      const response = await fetch(autosaveUrl, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': csrfToken || '',
        },
        body: formData,
      });

      if (response.ok) {
        const data = await response.json();
        lastSavedContentRef.current = html;
        updateStatus('saved', data.saved_at);
      } else {
        console.error('Autosave failed:', response.statusText);
        updateStatus('error');
      }
    } catch (error) {
      console.error('Autosave error:', error);
      updateStatus('error');
    }
  }, [autosaveUrl, fieldName, updateStatus]);

  const handleChange = useCallback((editorState: EditorState, editor: LexicalEditor) => {
    // Clear any pending timeout
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    // Set new timeout for debounced save
    timeoutRef.current = setTimeout(() => {
      editorState.read(() => {
        const html = $generateHtmlFromNodes(editor, null);
        saveContent(html);
      });
    }, debounceMs);
  }, [debounceMs, saveContent]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  return (
    <OnChangePlugin onChange={handleChange} ignoreSelectionChange={true} />
  );
}

// Status indicator component
interface AutosaveStatusIndicatorProps {
  status: AutosaveStatus;
  savedAt?: string;
}

export function AutosaveStatusIndicator({ status, savedAt }: AutosaveStatusIndicatorProps): JSX.Element {
  const formatTime = (isoString: string) => {
    const date = new Date(isoString);
    return date.toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <div className={`autosave-status autosave-status--${status}`}>
      {status === 'idle' && <span></span>}
      {status === 'saving' && <span>保存中...</span>}
      {status === 'saved' && (
        <span>
          保存済み {savedAt && `(${formatTime(savedAt)})`}
        </span>
      )}
      {status === 'error' && <span>保存に失敗しました</span>}
    </div>
  );
}
