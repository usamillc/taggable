class MergeValue < ApplicationRecord
  belongs_to :merge_attribute

  has_many :merge_tags, -> { where(status: [:not_approved, :approved]) }

  has_one :merge_task, through: :merge_attribute

  def n_tags_left
    merge_tags.not_approved.count
  end

  def increment_count!
    self.annotator_count = annotator_count + 1
    save!
  end
end
