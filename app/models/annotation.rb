class Annotation < ApplicationRecord
  belongs_to :annotation_attribute
  belongs_to :annotator
  belongs_to :task_paragraph

  has_one :category, through: :annotation_attribute

  def open_tag
    "<span class=\"tag\" data-annotationid=#{id}>&lt;#{annotation_attribute.tag}&gt;</span>"
  end

  def close_tag
    "<span class=\"tag\" data-annotationid=#{id}>&lt;/#{annotation_attribute.tag}&gt;</span>"
  end

  def transfer!(tp, identical=false)
    unless identical
      i = tp.no_tag.index(self.value)
      self.start_offset = i
      self.end_offset = i + self.value.length
    end
    return if self.start_offset.nil? || self.end_offset.nil?
    unless tp.no_tag[self.start_offset...self.end_offset] == self.value
      raise ActiveRecord::Rollback
    end
    self.task_paragraph = tp
    save
  end
end
