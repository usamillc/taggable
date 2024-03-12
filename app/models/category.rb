class Category < ApplicationRecord
  has_many :pages
  has_many :annotation_attributes, -> { where(deleted: false).order('ord ASC').order('id ASC') }
  has_many :linkable_attributes, -> { where(deleted: false, linkable: true) }, class_name: 'AnnotationAttribute'
  has_many :tasks, through: :pages
  has_many :task_paragraphs, through: :tasks
  has_many :annotations, through: :task_paragraphs
  has_many :annotators, through: :tasks
  has_many :imports, -> { order('created_at ASC') }

  has_many :merge_tasks, through: :pages
  has_many :merge_attributes, through: :merge_tasks
  has_many :merge_values, through: :merge_attributes
  has_many :merge_tags, through: :merge_values

  has_many :link_tasks, through: :pages
  has_many :link_annotations, through: :link_tasks
  has_many :entity_links, through: :link_tasks

  has_many :link_merge_tasks, through: :pages
  has_many :link_merge_annotations, through: :link_merge_tasks
  has_many :annotated_entity_links, through: :link_merge_tasks

  validates :screenname, presence: true, uniqueness: true

  enum status: [:active, :hidden]

  def prepare_merge!
    pages.each do |page|
      page.prepare_merge! if page.mergeable?
    end
  end

  def prepare_link!
    pages.each do |page|
      page.prepare_link! if page.linkable?
    end
  end

  def prepare_link_merge!
    pages.each do |page|
      page.prepare_link_merge! if page.link_mergeable?
    end
  end

  def mergeable_count
    pages.includes(:merge_task, :tasks).count { |p| p.mergeable? }
  end

  def linkable_count
    pages.includes(:merge_task, :link_tasks).count { |p| p.linkable? }
  end

  def link_mergeable_count
    pages.includes(:link_tasks, :link_merge_task).count { |p| p.link_mergeable? }
  end

  def concat_attributes(a1, a2, new_name, new_tag)
    aa1 = annotation_attributes.find_by(screenname: a1)
    raise RuntimeError unless aa1
    aa2 = annotation_attributes.find_by(screenname: a2)
    raise RuntimeError unless aa2

    puts "#{a1}: #{aa1.annotations.count}"
    puts "#{a2}: #{aa2.annotations.count}"
    puts "merging as [#{new_name}]"

    ActiveRecord::Base.transaction do
      aa2.annotations.update_all(annotation_attribute_id: aa1.id)
      aa2.annotations.delete_all
      aa2.delete
      aa1.update_attributes(name: new_tag, screenname: new_name)
    end

    aa = annotation_attributes.find_by(screenname: new_name)

    puts "#{aa.screenname}: #{aa.annotations.count}"
  end
end
