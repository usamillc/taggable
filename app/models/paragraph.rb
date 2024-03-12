class Paragraph < ApplicationRecord
  belongs_to :page
  has_one :task_paragraph
  has_many :merge_tags

  def previous
    page.paragraphs.where('id < ?', id).last
  end

  def match(orig_text, s, e)
    no_tag_i = 0
    orig_i = 0

    start_offset = nil
    orig_text.each_char.with_index do |c, i|
      if c == no_tag[no_tag_i]
        if start_offset.nil? && i == s
          start_offset = no_tag_i
        end
        if no_tag[no_tag_i] == '&' && no_tag[no_tag_i...no_tag_i+5] == '&amp;'
          no_tag_i += 5
        else
          no_tag_i += 1
        end
      elsif no_tag[no_tag_i] == '&' && (c == '>' || c == '<')
        if start_offset.nil? && i == s
          start_offset = no_tag_i
        end
        no_tag_i += 4
      end
    end
    return start_offset, no_tag_i
  end
end
