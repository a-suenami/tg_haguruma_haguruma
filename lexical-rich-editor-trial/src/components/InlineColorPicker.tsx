import { useState, useRef, useEffect } from 'react';

interface InlineColorPickerProps {
  onColorSelect: (color: string) => void;
}

export default function InlineColorPicker({ onColorSelect }: InlineColorPickerProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedColor, setSelectedColor] = useState('#FF0000');
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleColorClick = (color: string) => {
    setSelectedColor(color);
    onColorSelect(color);
    setIsOpen(false);
  };

  // より豊富なカラーパレット
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
        className="color-picker-trigger"
        onClick={() => setIsOpen(!isOpen)}
        style={{ backgroundColor: selectedColor }}
        title="More colors..."
      >
        <span className="color-picker-arrow">▼</span>
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
                    className="dropdown-color-button"
                    style={{ backgroundColor: color }}
                    onClick={() => handleColorClick(color)}
                    title={color}
                  />
                ))}
              </div>
            </div>
          ))}
          
          {/* Hex入力 */}
          <div className="color-input-section">
            <label className="hex-input-label">
              Hex: 
              <input
                type="text"
                className="hex-input"
                value={selectedColor}
                onChange={(e) => {
                  const value = e.target.value;
                  if (/^#[0-9A-F]{6}$/i.test(value)) {
                    setSelectedColor(value);
                  }
                }}
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    if (/^#[0-9A-F]{6}$/i.test(selectedColor)) {
                      onColorSelect(selectedColor);
                      setIsOpen(false);
                    }
                  }
                }}
                placeholder="#FF0000"
              />
            </label>
          </div>
        </div>
      )}
    </div>
  );
}