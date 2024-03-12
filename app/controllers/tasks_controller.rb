class TasksController < ApplicationController
  before_action :logged_in_annotator
  before_action :set_task, only: [:show, :start, :finish, :attributes, :values_for]

  def index
    @categories = Category.active.pluck(:id, :screenname).uniq

    if params[:category_id]
      @unscoped_tasks = Task.includes(page: :category).where('categories.id': params[:category_id])
    else
      @unscoped_tasks = Task.includes(page: :category).where(categories: { status: :active })
    end
    @unscoped_tasks = @unscoped_tasks.order('pages.category_id').order('pages.aid')

    if params[:status]
      @all_tasks = @unscoped_tasks.where(status: params[:status])
    else
      @all_tasks = @unscoped_tasks
    end
    @tasks = @all_tasks.page(params[:page]).includes(page: :category)
    sql = "SELECT tasks.id, COUNT(annotations.id) FROM tasks INNER JOIN task_paragraphs on tasks.id = task_paragraphs.task_id INNER JOIN annotations on task_paragraphs.id = annotations.task_paragraph_id WHERE tasks.id IN (#{@tasks.pluck(:id).join(',')}) AND annotations.deleted = false AND annotations.dummy = false GROUP BY tasks.id;"
    @annotation_counts = @tasks.empty? ? 0 : ActiveRecord::Base.connection.execute(sql).values.to_h
  end

  def show
    @plain_view = params.fetch(:plain, 'false') == 'true'
    @attributes = @task.annotation_attributes
    @attribute2values = begin
                          h = Hash.new{|h, k| h[k] = []}
                          Annotation.where(task_paragraph_id: @task.task_paragraphs.pluck(:id), deleted: false).map {|a| h[a.annotation_attribute_id].push a.value}
                          h.each do |k, values|
                            h[k] = values.sort.uniq
                          end
                          h
                        end
    @main_y = params.fetch(:main_y, 0).to_i
    @attribute_id = params.fetch(:attribute_id, @attributes.first.id).to_i
    @highlights = params.fetch(:highlights, '').split('|')
  end

  def start
    @task.start!(current_annotator)
    redirect_to @task
  end

  def finish
    @task.finish!(current_annotator)
    redirect_to tasks_url(category_id: params[:category_id], status: params[:status])
  end

  def attributes
    render json: @task.annotation_attributes
  end

  def values_for
    render json: Annotation.where(task_paragraph_id: @task.task_paragraphs.pluck(:id), deleted: false, annotation_attribute_id: params[:attribute_id])
  end

  private

  def set_task
    @task = Task.find_by!(id: params[:id])
  end
end
