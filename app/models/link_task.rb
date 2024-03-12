class LinkTask < ApplicationRecord
  belongs_to :page
  belongs_to :last_changed_annotator, class_name: 'Annotator', foreign_key: 'annotator_id', optional: true

  has_one :category, through: :page
  has_one :merge_task, through: :page

  has_many :link_annotations, -> { order 'id ASC' }
  has_many :incomplete_annotations, -> { where status: :incomplete }, class_name: 'LinkAnnotation'
  has_many :merge_tags, through: :link_annotations
  has_many :entity_links, through: :link_annotations

  enum status: [:not_started, :in_progress, :completed]

  class << self
    def prepare!(page)
      task = self.create!(page: page)
      linkable = Set.new(page.linkable_attributes.pluck(:screenname))
      page.merge_tags.approved.includes(:merge_attribute).each do |mt|
        if linkable.include? mt.merge_attribute.screenname
          la = LinkAnnotation.create!(link_task: task, merge_tag: mt)
          la.generate_suggests!
        end
      end
    end
  end

  def annotations_by_pid
    link_annotations.includes(:merge_tag).inject({}) do |hash, la|
      pid = la.merge_tag.paragraph_id
      hash[pid] = [] unless hash.key? pid
      hash[pid] << la
      hash
    end
  end

  def approved_link_titles_by_value
    entity_links.approved.inject({}) do |hash, l|
      v = l.merge_value.value
      hash[v] = {} unless hash.key? v
      hash[v][l.title] = 0 unless hash[v].key? l.title
      hash[v][l.title] += 1
      hash
    end
  end

  def approved_link_titles_by_attribute
    entity_links.approved.inject({}) do |hash, l|
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
    incomplete_annotations.count.zero?
  end
end
