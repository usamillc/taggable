class MergeTask < ApplicationRecord
  belongs_to :page
  belongs_to :last_changed_annotator, class_name: 'Annotator', foreign_key: 'annotator_id', optional: true

  has_one :category, through: :page

  has_many :merge_attributes, -> { order 'id ASC' }
  has_many :merge_values, through: :merge_attributes
  has_many :merge_tags, -> { order 'paragraph_id, start_offset' }, through: :merge_values

  enum status: [:not_started, :in_progress, :completed]

  def start!(annotator)
    update_attributes(status: :in_progress, last_changed_annotator: annotator)
  end

  def finish!(annotator)
    update_attributes(status: :completed, last_changed_annotator: annotator)
  end

  def completable?
    merge_attributes.not_completed.empty?
  end
end
