class MergeAttribute < ApplicationRecord
  belongs_to :merge_task

  has_one :page, through: :merge_task

  has_many :merge_values, -> { order 'id ASC' }
  has_many :merge_tags, through: :merge_values

  enum status: [:not_completed, :completed]

  def tag
    name.upcase
  end

  def completable?
    merge_tags.not_approved.empty?
  end
end
