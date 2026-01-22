module SvgHelper
  # Base directories for SVG files
  SVG_BASES = {
    assets: 'app/assets/images',
    frontend: 'app/frontend/assets',
  }.freeze

  # Renders an SVG file inline for proper CSS styling
  # @param path [String] Path to the SVG file relative to the base directory
  # @param options [Hash] Options for customizing SVG output
  # @option options [Symbol] :base Base directory (:assets or :frontend, default: :assets)
  # @option options [String] :class CSS class to add to the SVG element
  # @option options [String] :id ID to add to the SVG element
  # @return [ActiveSupport::SafeBuffer] The SVG content
  def inline_svg(path, options = {})
    base = options.delete(:base) || :assets
    base_path = SVG_BASES[base] || SVG_BASES[:assets]
    file_path = Rails.root.join(base_path, path)
    return '' unless File.exist?(file_path)

    svg_content = File.read(file_path)
    process_svg_content(svg_content, options)
  end

  # Renders an icon SVG from app/assets/images/icons
  # @param icon_name [String] Icon name (sign-in-indicator, sign-up-indicator, etc.)
  # @return [ActiveSupport::SafeBuffer] The SVG content
  def icon_svg(icon_name)
    inline_svg("icons/icon_#{icon_name}.svg")
  end

  private

  def process_svg_content(svg_content, options = {})
    # Remove XML declaration if present
    svg_content = svg_content.gsub(/<\?xml[^>]*\?>/, '').strip

    # Add class or id if provided
    if options[:class] || options[:id]
      attrs = []
      attrs << "class=\"#{options[:class]}\"" if options[:class]
      attrs << "id=\"#{options[:id]}\"" if options[:id]
      svg_content = svg_content.sub('<svg', "<svg #{attrs.join(' ')}")
    end

    svg_content.html_safe
  end
end
