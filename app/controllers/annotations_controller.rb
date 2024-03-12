class AnnotationsController < ApplicationController
  include AnnotationsHelper

  before_action :logged_in_admin, only: [:index]

  def index
    annotators_ids = current_annotator.organization.annotators.pluck(:id)
    @unscoped = Annotation.where(annotator_id: annotators_ids, deleted: false).includes(:annotation_attribute)
    @categories = Category.all.pluck('categories.id', :screenname).uniq

    if params[:category_id]
      @unscoped = @unscoped.joins(:category).where('categories.id': params[:category_id])
    end
    if params[:attribute_id]
      @all = @unscoped.where(annotation_attribute_id: params[:attribute_id])
    else
      @all = @unscoped
    end
    @annotations = @all.includes(:annotator).includes(annotation_attribute: :category).includes(task_paragraph: {task: :page}).page(params[:page])
  end

  def create
    value = params[:annotation][:value]

    before_end_offset = params[:annotation][:end_offset].to_i
    if value.end_with? ' ' or value.end_with? "\n"
      c = value.length
      value.rstrip!
      before_end_offset -= c - value.length
    end

    before_start_offset = params[:annotation][:start_offset].to_i
    if value.start_with? ' ' or value.start_with? "\n"
      c = value.length
      value.lstrip!
      before_start_offset -= c - value.length
    end

    paragraph = TaskParagraph.find(params[:annotation][:paragraph_id])

    unless paragraph.no_tag.include? html_escape(value)
      paragraph = paragraph.page.task_paragraphs.where('task_paragraphs.id > ?', paragraph.id).order(:id).find { |p| p.no_tag.include? value }
    end

    if paragraph.nil?
      a = AnnotationAttribute.find(params[:annotation][:annotation_attribute_id])
      p = TaskParagraph.find(params[:annotation][:paragraph_id])
      Raven.tags_context params[:annotation].permit!
      Raven.tags_context annotation_attribute: a.screenname
      Raven.tags_context category: a.category.screenname
      Raven.tags_context page_title: p.page.title
      Raven.tags_context page_aid: p.page.aid
      Raven.extra_context text: params[:annotation][:text]
      Raven.capture_message('Taggable: Annotation Failure [no paragraph match]')
      flash[:danger] = 'アノテーションに失敗しました。'
      return head :bad_request
    end

    start_offset, end_offset = paragraph.match(
      params[:annotation][:text][0...before_end_offset],
      before_start_offset,
      before_end_offset
    )

    if start_offset.nil? || end_offset.nil? || html_escape(value) != paragraph.no_tag[start_offset...end_offset]
      Raven.tags_context params[:annotation].permit!
      Raven.tags_context annotation_attribute: AnnotationAttribute.find(params[:annotation][:annotation_attribute_id])&.screenname
      Raven.tags_context category: paragraph.page.category.screenname
      Raven.tags_context page_title: paragraph.page.title
      Raven.tags_context page_aid: paragraph.page.aid
      Raven.extra_context start_offset: start_offset, end_offset: end_offset, value: value
      Raven.extra_context text: params[:annotation][:text]
      if start_offset && end_offset
        Raven.extra_context matched: paragraph.no_tag[start_offset...end_offset]
      end
      Raven.capture_message('Taggable: Annotation Failure [not valid offset match]')
      flash[:danger] = 'アノテーションに失敗しました。'
      return head :bad_request
    end

    annotator_id = current_annotator.id

    ActiveRecord::Base.transaction do
      @annotation = Annotation.create!(
        task_paragraph: paragraph,
        annotator_id: annotator_id,
        annotation_attribute_id: params[:annotation][:annotation_attribute_id],
        start_offset: start_offset,
        end_offset: end_offset,
        value: value,
      )
      task = paragraph.task
      task.last_changed_annotator = current_annotator
      task.save!
      Revision.create!(
        action: 'create',
        annotation: @annotation,
        annotator_id: annotator_id,
        task_id: task.id
      )
      Revision.where(task_id: task.id, undone: true).delete_all
      paragraph.build_tags!
    end
    return render json: @annotation if @annotation
  end

  def destroy
    annotation = Annotation.find(params[:annotation][:annotation_id])
    if annotation
      ActiveRecord::Base.transaction do
        annotation.deleted = true
        annotation.save!

        task = annotation.task_paragraph.task
        task.last_changed_annotator = current_annotator
        task.save!
        Revision.create!(
          action: 'delete',
          annotation: annotation,
          annotator_id: current_annotator.id,
          task_id: task.id
        )
        Revision.where(task_id: task.id, undone: true).delete_all
        annotation.task_paragraph.build_tags!
      end
      return render json: annotation
    end
  end

  def undo
    task = Task.find(params[:task_id])
    if task.current_revision
      ActiveRecord::Base.transaction do
        task.last_changed_annotator = current_annotator
        task.save!
        task.current_revision.undone = true
        task.current_revision.save!
        a = task.current_revision.annotation
        a.deleted = task.current_revision.action == 'create'
        a.save!
        a.task_paragraph.build_tags!
      end
    end
  end

  def redo
    task = Task.find(params[:task_id])
    if task.next_revision
      ActiveRecord::Base.transaction do
        task.last_changed_annotator = current_annotator
        task.save!
        task.next_revision.undone = false
        task.next_revision.save!
        a = task.next_revision.annotation
        a.deleted = task.next_revision.action == 'delete'
        a.save!
        a.task_paragraph.build_tags!
      end
    end
  end
end
