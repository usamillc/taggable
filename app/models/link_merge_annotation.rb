class LinkMergeAnnotation < ApplicationRecord
  validate :to_have_no_conflicted_entity_links, :if => lambda{ |lma| lma.completed? }

  belongs_to :link_merge_task
  belongs_to :merge_tag

  has_one :merge_value, through: :merge_tag
  has_one :merge_attribute, through: :merge_value
  has_one :page, through: :link_merge_task

  has_many :annotated_entity_links

  delegate :start_offset, to: :merge_tag
  delegate :end_offset, to: :merge_tag

  enum status: [:incomplete, :completed]

  class << self
    def prepare!(link_merge_task, merge_tag)
      lma = self.create!(
        link_merge_task: link_merge_task,
        merge_tag: merge_tag,
        no_link_count: merge_tag.link_annotations.count {|a| a.no_link? }
      )

      merge_tag.entity_links.approved.group_by(&:title).each do |_, entity_links|
        a = AnnotatedEntityLink.create_by_consensus!(lma, entity_links)
        begin
          a.approved!
        rescue ActiveRecord::RecordInvalid
        end
      end

      begin
        lma.completed!
      rescue ActiveRecord::RecordInvalid
      end
    end
  end

  def next
    found_self = false
    link_merge_task.link_merge_annotations.each do |a|
      return a if found_self && a.incomplete?
      found_self = true if a == self
    end
    nil
  end

  def no_link?
    annotated_entity_links.empty? || annotated_entity_links.all? { |a| a.rejected? || a.new_record? }
  end

  def to_have_no_conflicted_entity_links
    unless annotated_entity_links.none? { |a| a.conflicted? }
      msg = 'アノテーション結果を確定していないリンク候補があります。'
      errors.add(:base, msg)
    end
  end
end
