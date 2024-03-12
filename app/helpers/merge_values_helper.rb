module MergeValuesHelper
  def highlight_value(html, v)
    v = html_escape(v)

    tags = []
    no_tags = []

    start = nil
    in_tag = false
    tag = ''
    no_tag = ''
    html.each_char do |c|
      unless start
        if c == '<'
          start = 'tag'
        else
          start = 'no_tag'
        end
      end
      if c == '<'
        in_tag = true
        unless no_tag.empty?
          no_tags << no_tag
          no_tag = ''
        end
      end

      if in_tag
        tag += c
      else
        no_tag += c
      end

      if c == '>'
        in_tag = false
        tags << tag
        tag = ''
      end
    end

    no_tags << no_tag unless no_tag.empty?

    no_tags.map! { |no_tag| no_tag.gsub v, "<mark>#{v}</mark>" }

    if start == 'tag'
      html = tags.zip(no_tags).flatten.join('')
    else
      html = no_tags.zip(tags).flatten.join('')
    end

    html
  end

  def build_tag(paragraph, merge_tags, attribute_tag=nil)
    html = ''

    tags = merge_tags
      .sort { |x,y| x.start_offset <=> y.start_offset }
      .uniq { |t| [t.start_offset, t.end_offset] }

    no_tag_i = 0
    tag = tags.shift

    in_tag = false

    i = 0
    while i < paragraph.body.length
      c = paragraph.body[i]
      if c == '<'
        in_tag = true
      elsif c == '>'
        in_tag = false
      end
      unless !in_tag && c == paragraph.no_tag[no_tag_i]
        html << c
        i += 1
        next
      end

      if tag&.start_offset == no_tag_i
        diff = tag.end_offset - tag.start_offset
        value = paragraph.body[i...(i + diff)]
        if tag.not_approved?
          html << render('merge/approve_dropdown', tag: set_tag(attribute_tag, tag), merge_tag: tag, value: value)
        else
          html << render('merge/tag', tag: set_tag(attribute_tag, tag), merge_tag: tag, value: value).strip!
        end
        no_tag_i += diff
        i += diff
        tag = tags.shift
      else
        html << c
        no_tag_i += 1
        i += 1
      end
    end

    html
  end

  def set_tag(tag, merge_tag)
    tag ? tag : merge_tag.merge_value.merge_attribute.tag
  end
end
