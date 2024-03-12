class LinkAnnotation < ApplicationRecord
  belongs_to :link_task
  belongs_to :merge_tag

  has_one :merge_value, through: :merge_tag
  has_one :merge_attribute, through: :merge_value
  has_one :page, through: :link_task

  has_many :entity_links, dependent: :delete_all

  enum status: [:incomplete, :completed]

  def next
    found_self = false
    link_task.link_annotations.each do |a|
      return a if found_self && a.incomplete?
      found_self = true if a == self
    end
    nil
  end

  def same_entities
    link_task.link_annotations.where(merge_tag_id: merge_value.merge_tags.pluck(:id))
  end

  def start_offset
    merge_tag.start_offset
  end

  def end_offset
    merge_tag.end_offset
  end

  def no_link?
    completed? && entity_links.all? { |e| e.new_record? || e.rejected? }
  end

  def title_matched_suggest_exists?
    entity_links.any? { |e| e.title == merge_value.value }
  end

  def generate_suggests!
    LinkAnnotationsHelper::Suggester.instance.suggests(merge_value.value).each do |s|
      entity_links.create(s)
    end
  end
end
