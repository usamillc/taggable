module PagesHelper
  TAGS_WHITE_LIST = %w(h1 h2 h3 h4 h5 table tr th br td p ul ol li).freeze

  def sanitize(html)
    ActionView::Base.white_list_sanitizer.sanitize(html, tags: TAGS_WHITE_LIST, attributes: [])
  end

  def trim(html)
    body = ''
    trim = true
    html.each_line do |line|
      if line.start_with? '<body'
        trim = false
      elsif line.start_with? '<!--'
        trim = true
      elsif line.start_with? '<table class="asbox plainlinks noprint"'
        trim = true
      # elsif line.start_with? '				<div id="mw-content-text"'
      #   next
      end
      body += line unless trim
    end
    return body
  end

  def load_html(page, htmlfile, debug=false, return_body=false)
    body = File.open(htmlfile) do |f|
      ActionView::Base.white_list_sanitizer.sanitize(trim(f.read), tags: TAGS_WHITE_LIST, attributes: [])
    end

    if debug
      File.open('tmp/original.html', 'w') do |f|
        f.write(body)
      end
    end

    body = body.gsub(/\t/, '')
      .gsub(/\n+/, "\n")
      .gsub(/\n([^<])/, '\1')
      .gsub(/\n<\/p>/, "</p>\n")
      .gsub(/<table>/, "<table>\n")
      .gsub(/<\/(.+?)>/, "</\\1>\n")
      .gsub(/<br>/, ' ')
      .gsub(/<li>(.+?)<\/li>/, "<li>\n\\1\n</li>")
      .gsub(/> </, ">\n<")
      .gsub(/<\/ul>(.+?)\n/, "</ul>\n\\1\n")
      .gsub(/\n\s+/, "\n")
      .gsub(/<th>(.+?)\n/, "<th>\n\\1\n")
      .gsub(/<td>\n/, '<td>')
      .gsub(/<td>(.+?)\n/, "<td>\n|\\1\n")
      .gsub(/<tr>/, "\n<tr>\n")
      .gsub(/<\/th>/, "\n</th>")
      .gsub(/<\/td>/, "\n</td>")
      .gsub(/<\/tr>/, "\n</tr>")
      .gsub(/<\/table>/, "\n</table>")
      .gsub(/<table>/, "<table class=\"table\">")
      .gsub(/&lt;(.+?)&gt;/, ' ')
      .gsub(/\n+/, "\n")

    paragraphs = body.split(/\n+/)
    paragraphs.map! { |p| p.strip }
    paragraphs.select! { |p| not p.blank? }

    return paragraphs if return_body

    if debug
      File.open('tmp/snitized.html', 'w') do |f|
        f.write(body)
      end
    else
      paragraphs.each do |p|
        build_paragraph(page, p)
      end
    end
  end

  def build_paragraph(page, p)
    return if p.blank?
    no_tag = ActionView::Base.white_list_sanitizer.sanitize(p, tags: []).strip
    Paragraph.create!(page: page, body: p, no_tag: no_tag)
  end
end
