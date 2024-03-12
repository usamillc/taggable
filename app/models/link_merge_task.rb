class LinkMergeTask < ApplicationRecord
  belongs_to :page
  belongs_to :last_changed_annotator, class_name: 'Annotator', foreign_key: 'annotator_id', optional: true

  has_one :category, through: :page

  has_many :link_merge_annotations, -> { order 'id ASC' }
  has_many :link_tasks, through: :page
  has_many :link_annotations, through: :link_tasks
  has_many :merge_tags, through: :link_annotations
  has_many :annotated_entity_links, through: :link_merge_annotations

  enum status: [:not_started, :in_progress, :completed]

  class << self
    def prepare!(page)
      task = self.create!(page: page)

      linkable = Set.new(page.linkable_attributes.pluck(:screenname))
      page.merge_tags.approved.includes(:merge_attribute).each do |mt|
        if linkable.include? mt.merge_attribute.screenname

          LinkMergeAnnotation.prepare!(task, mt)
        end
      end
    end
  end

  def annotations_by_pid
    link_merge_annotations.includes(:merge_tag).inject({}) do |hash, lma|
      pid = lma.merge_tag.paragraph_id
      hash[pid] = [] unless hash.key? pid
      hash[pid] << lma
      hash
    end
  end

  def approved_link_titles_by_value
    annotated_entity_links.approved.inject({}) do |hash, l|
      v = l.merge_value.value
      hash[v] = {} unless hash.key? v
      hash[v][l.title] = 0 unless hash[v].key? l.title
      hash[v][l.title] += 1
      hash
    end
  end

  def approved_link_titles_by_attribute
    annotated_entity_links.approved.inject({}) do |hash, l|
      a = l.merge_attribute.screenname
      hash[a] = {} unless hash.key? a
      hash[a][l.title] = 0 unless hash[a].key? l.title
      hash[a][l.title] += 1
      hash
    end
  end

  def start!(annotator)
    update_attributes(status: :in_progress, last_changed_annotator: annotator)
  end

  def finish!(annotator)
    update_attributes(status: :completed, last_changed_annotator: annotator)
  end

  def completable?
    link_merge_annotations.incomplete.empty?
  end
end
