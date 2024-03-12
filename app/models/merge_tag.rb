class MergeTag < ApplicationRecord
  validates :merge_value_id, uniqueness: { scope: [:paragraph_id, :start_offset, :end_offset, :status] }, if: -> { not deleted? }
  validates :start_offset, presence: true
  validates :end_offset, presence: true
  validate :start_offset_cannot_overwrap, :if => lambda{ |o| o.approved? }
  validate :end_offset_cannot_overwrap, :if => lambda{ |o| o.approved? }

  belongs_to :merge_value
  belongs_to :paragraph

  has_one :merge_attribute, through: :merge_value

  has_many :link_annotations
  has_many :entity_links, through: :link_annotations

  enum status: [:not_approved, :approved, :deleted]

  def determined?
    !not_approved?
  end

  def link_completed?
    false
  end

  def start_offset_cannot_overwrap
    tags = paragraph.merge_tags.approved.where("start_offset < #{start_offset} AND end_offset > #{start_offset} AND end_offset < #{end_offset}")
    unless tags.empty?
      tag = tags.first
      msg = "他のタグと重なっています。\n重なっているタグ: [#{tag.merge_value.merge_attribute.screenname}]#{tag.merge_value.value}"
      errors.add(:start_offset, msg)
    end
  end

  def end_offset_cannot_overwrap
    tags = paragraph.merge_tags.approved.where("#{start_offset} < start_offset AND start_offset < #{end_offset - 1} AND end_offset > #{end_offset}")
    unless tags.empty?
      tag = tags.first
      msg = "他のタグと重なっています。\n重なっているタグ: [#{tag.merge_value.merge_attribute.screenname}]#{tag.merge_value.value}"
      errors.add(:end_offset, msg)
    end
  end
end
