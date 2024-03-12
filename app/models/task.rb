class Task < ApplicationRecord
  belongs_to :page
  belongs_to :organization
  belongs_to :last_changed_annotator, class_name: 'Annotator', foreign_key: 'annotator_id', optional: true
  belongs_to :annotator, optional: true
  belongs_to :import, optional: true

  has_many :task_paragraphs, -> { order 'id ASC' }, dependent: :delete_all
  has_many :annotation_attributes, through: :page
  has_many :annotations, through: :task_paragraphs

  has_one :current_revision, -> { where(undone: false).order(created_at: :desc) }, class_name: 'Revision'
  has_one :next_revision, -> { where(undone: true).order(created_at: :asc) }, class_name: 'Revision'
  has_one :category, through: :page

  enum status: [:not_started, :in_progress, :completed]

  class << self
    def import(import, page)
      t = Task.create!(page: page, organization: import.annotator.organization, import: import)
      page.paragraphs.each do |p|
        TaskParagraph.create!(paragraph: p, task: t, body: p.body, no_tag: p.no_tag)
      end
    end
  end

  def start!(annotator)
    update_attributes(status: :in_progress, last_changed_annotator: annotator)
  end

  def finish!(annotator)
    update_attributes(status: :completed, last_changed_annotator: annotator)
  end
end
