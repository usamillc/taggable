class TaskParagraph < ApplicationRecord
  belongs_to :task
  belongs_to :paragraph

  has_one :page, through: :paragraph
  has_many :annotations, -> { where(deleted: false, dummy: false) }

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

  def build_tags!
    html = ''

    open_tags = []
    close_tags = []

    annotations.order(:start_offset).order(end_offset: :desc, id: :asc).each do |a|
      open_tags.push [a.start_offset, a.open_tag]
    end
    annotations.order(:end_offset, id: :desc).each do |a|
      close_tags.push [a.end_offset, a.close_tag]
    end

    no_tag_i = 0
    open_tag = open_tags.shift
    close_tag = close_tags.shift

    body.each_char do |c|
      unless c == no_tag[no_tag_i]
        html << c
        next
      end

      while open_tag&.first == no_tag_i
        html << open_tag.second
        open_tag = open_tags.shift
      end

      html << c
      no_tag_i += 1

      while close_tag&.first == no_tag_i
        html << close_tag.second
        close_tag = close_tags.shift
      end
    end

    self.tagged = html
    self.save!
  end
end
