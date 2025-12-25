module SvgHelper
  # Renders an SVG file inline for proper CSS styling
  # @param path [String] Path to the SVG file relative to public directory
  # @return [ActiveSupport::SafeBuffer] The SVG content
  def inline_svg(path)
    file_path = Rails.root.join('public', path)
    return '' unless File.exist?(file_path)

    svg_content = File.read(file_path)
    # Remove XML declaration if present
    svg_content = svg_content.gsub(/<\?xml[^>]*\?>/, '').strip
    svg_content.html_safe
  end

  # Renders a feature title image SVG
  # @param feature [String] Feature name (news, blog, schedule, etc.)
  # @return [ActiveSupport::SafeBuffer] The SVG content
  def feature_title_svg(feature)
    inline_svg("assets/features/#{feature}/#{feature}-overview-title.svg")
  end
end
