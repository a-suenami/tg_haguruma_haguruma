import { useEffect, useRef, useCallback } from 'react';
import { useLexicalComposerContext } from '@lexical/react/LexicalComposerContext';
import { OnChangePlugin } from '@lexical/react/LexicalOnChangePlugin';
import type { EditorState, LexicalEditor } from 'lexical';

interface HiddenFieldSyncPluginProps {
  hiddenFieldId: string;
  debounceMs?: number;
}

export default function HiddenFieldSyncPlugin({
  hiddenFieldId,
  debounceMs = 300,
}: HiddenFieldSyncPluginProps): JSX.Element {
  const [editor] = useLexicalComposerContext();
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const syncToHiddenField = useCallback((editorState: EditorState, _editor: LexicalEditor) => {
    // Clear pending timeout
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    // Debounce the sync
    timeoutRef.current = setTimeout(() => {
      // Serialize editor state to Lexical JSON
      const json = JSON.stringify(editorState.toJSON());
      const hiddenField = document.getElementById(hiddenFieldId) as HTMLInputElement | null;

      if (hiddenField) {
        hiddenField.value = json;

        // Dispatch custom event for autosave controller
        const event = new CustomEvent('lexical:change', {
          bubbles: true,
          detail: { json },
        });
        hiddenField.dispatchEvent(event);
      }
    }, debounceMs);
  }, [hiddenFieldId, debounceMs]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  return (
    <OnChangePlugin onChange={syncToHiddenField} ignoreSelectionChange={true} />
  );
}
