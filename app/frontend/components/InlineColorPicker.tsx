import { useState, useRef, useEffect, useCallback } from 'react';
import { LexicalEditor, $getSelection, $setSelection, RangeSelection } from 'lexical';
import { $patchStyleText } from '@lexical/selection';
import { Palette } from 'lucide-react';

interface InlineColorPickerProps {
  editor: LexicalEditor;
}

export default function InlineColorPicker({ editor }: InlineColorPickerProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedColor, setSelectedColor] = useState('#000000');
  const [savedSelection, setSavedSelection] = useState<RangeSelection | null>(null);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
        setSavedSelection(null);
      }
    }

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleOpenPicker = useCallback(() => {
    // Save current selection before opening
    editor.getEditorState().read(() => {
      const selection = $getSelection();
      if (selection && selection.isCollapsed !== undefined) {
        setSavedSelection(selection.clone() as RangeSelection);
      }
    });
    setIsOpen(!isOpen);
  }, [editor, isOpen]);

  const handleColorClick = useCallback((color: string) => {
    setSelectedColor(color);

    editor.update(() => {
      // Restore saved selection
      if (savedSelection) {
        $setSelection(savedSelection.clone());
      }

      const selection = $getSelection();
      if (selection && !selection.isCollapsed()) {
        $patchStyleText(selection, {
          color: color,
        });
      }
    });

    setIsOpen(false);
    setSavedSelection(null);

    // Return focus to editor
    editor.focus();
  }, [editor, savedSelection]);

  const handleHexInput = useCallback((value: string) => {
    if (/^#[0-9A-Fa-f]{6}$/.test(value)) {
      setSelectedColor(value);
    }
  }, []);

  const handleHexSubmit = useCallback(() => {
    if (/^#[0-9A-Fa-f]{6}$/.test(selectedColor)) {
      handleColorClick(selectedColor);
    }
  }, [selectedColor, handleColorClick]);

  // Color palette
  const colorSections = [
    // 基本色
    {
      name: 'Basic Colors',
      colors: [
        '#000000', '#FFFFFF', '#FF0000', '#00FF00', '#0000FF', '#FFFF00', '#FF00FF', '#00FFFF'
      ]
    },
    // グレー系
    {
      name: 'Grays',
      colors: [
        '#F8F8F8', '#E8E8E8', '#D3D3D3', '#C0C0C0', '#A8A8A8', '#808080', '#696969', '#404040'
      ]
    },
    // 暖色系
    {
      name: 'Warm Colors',
      colors: [
        '#FFE4E1', '#FFA07A', '#FA8072', '#E9967A', '#F08080', '#CD5C5C', '#DC143C', '#B22222'
      ]
    },
    // 寒色系
    {
      name: 'Cool Colors',
      colors: [
        '#E0F6FF', '#87CEEB', '#87CEFA', '#00BFFF', '#1E90FF', '#4169E1', '#0000CD', '#00008B'
      ]
    },
    // 緑系
    {
      name: 'Greens',
      colors: [
        '#F0FFF0', '#98FB98', '#90EE90', '#32CD32', '#00FF32', '#228B22', '#008000', '#006400'
      ]
    },
    // カラフル
    {
      name: 'Vibrant',
      colors: [
        '#FF69B4', '#FF1493', '#FF6347', '#FF4500', '#FFA500', '#FFD700', '#ADFF2F', '#7FFF00'
      ]
    }
  ];

  return (
    <div className="inline-color-picker" ref={dropdownRef}>
      <button
        type="button"
        className="toolbar-item color-picker-trigger"
        onClick={handleOpenPicker}
        title="Text color"
      >
        <Palette size={16} />
        <span
          className="color-indicator"
          style={{ backgroundColor: selectedColor }}
        />
      </button>

      {isOpen && (
        <div className="color-picker-dropdown">
          {colorSections.map((section, sectionIndex) => (
            <div key={sectionIndex} className="color-section">
              <div className="section-title">{section.name}</div>
              <div className="section-colors">
                {section.colors.map((color, colorIndex) => (
                  <button
                    key={colorIndex}
                    type="button"
                    className="dropdown-color-button"
                    style={{ backgroundColor: color }}
                    onClick={() => handleColorClick(color)}
                    title={color}
                  />
                ))}
              </div>
            </div>
          ))}

          {/* Hex input */}
          <div className="color-input-section">
            <label className="hex-input-label">
              Hex:
              <input
                type="text"
                className="hex-input"
                value={selectedColor}
                onChange={(e) => handleHexInput(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    handleHexSubmit();
                  }
                }}
                placeholder="#000000"
              />
            </label>
          </div>
        </div>
      )}
    </div>
  );
}
