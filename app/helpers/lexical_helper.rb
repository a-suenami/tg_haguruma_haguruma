# typed: true
# frozen_string_literal: true

module LexicalHelper
  extend T::Sig

  # Convert Lexical JSON to simple HTML
  sig { params(lexical_json: T.nilable(T::Hash[String, T.untyped])).returns(String) }
  def lexical_to_html(lexical_json)
    return '' if lexical_json.nil?

    root = lexical_json['root']
    return '' if root.nil?

    children = root['children'] || []
    render_nodes(children)
  end

  private

  sig { params(nodes: T::Array[T.untyped]).returns(String) }
  def render_nodes(nodes)
    nodes.map { |node| render_node(node) }.join
  end

  sig { params(node: T::Hash[String, T.untyped]).returns(String) }
  def render_node(node)
    type = node['type']

    case type
    when 'paragraph'
      "<p>#{render_children(node)}</p>"
    when 'heading'
      tag = node['tag'] || 'h2'
      "<#{tag}>#{render_children(node)}</#{tag}>"
    when 'text'
      render_text_node(node)
    when 'link'
      url = node['url'] || '#'
      "<a href=\"#{ERB::Util.html_escape(url)}\" target=\"_blank\" rel=\"noopener\">#{render_children(node)}</a>"
    when 'list'
      tag = node['listType'] == 'number' ? 'ol' : 'ul'
      "<#{tag}>#{render_children(node)}</#{tag}>"
    when 'listitem'
      "<li>#{render_children(node)}</li>"
    when 'quote'
      "<blockquote>#{render_children(node)}</blockquote>"
    when 'image'
      src = node['src'] || ''
      alt = node['altText'] || ''
      "<img src=\"#{ERB::Util.html_escape(src)}\" alt=\"#{ERB::Util.html_escape(alt)}\" style=\"max-width: 100%;\">"
    when 'video'
      src = node['src'] || ''
      width = node['width'] || 640
      height = node['height'] || 360
      "<video src=\"#{ERB::Util.html_escape(src)}\" width=\"#{width}\" height=\"#{height}\" controls style=\"max-width: 100%;\"></video>"
    when 'auto-embed'
      render_auto_embed(node)
    when 'linebreak'
      '<br>'
    else
      render_children(node)
    end
  end

  sig { params(node: T::Hash[String, T.untyped]).returns(String) }
  def render_children(node)
    children = node['children'] || []
    render_nodes(children)
  end

  sig { params(node: T::Hash[String, T.untyped]).returns(String) }
  def render_text_node(node)
    text = ERB::Util.html_escape(node['text'] || '')
    format = node['format'] || 0

    # Lexical format flags: bold=1, italic=2, underline=8, strikethrough=4, code=16
    text = "<strong>#{text}</strong>" if (format & 1) != 0
    text = "<em>#{text}</em>" if (format & 2) != 0
    text = "<u>#{text}</u>" if (format & 8) != 0
    text = "<s>#{text}</s>" if (format & 4) != 0
    text = "<code>#{text}</code>" if (format & 16) != 0

    text
  end

  sig { params(node: T::Hash[String, T.untyped]).returns(String) }
  def render_auto_embed(node)
    embed_type = node['embedType']
    url = node['url'] || ''
    id = node['id'] || ''

    case embed_type
    when 'youtube'
      <<~HTML
        <div style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%;">
          <iframe src="https://www.youtube.com/embed/#{ERB::Util.html_escape(id)}"
                  style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"
                  frameborder="0" allowfullscreen></iframe>
        </div>
      HTML
    when 'twitter', 'x'
      "<blockquote><a href=\"#{ERB::Util.html_escape(url)}\" target=\"_blank\" rel=\"noopener\">View on X</a></blockquote>"
    else
      "<a href=\"#{ERB::Util.html_escape(url)}\" target=\"_blank\" rel=\"noopener\">#{ERB::Util.html_escape(url)}</a>"
    end
  end
end
