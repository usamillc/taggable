class MergeTasksController < ApplicationController
  before_action :merge_allowed_annotator
  before_action :set_merge_task, only: [:show, :start, :finish]

  def index
    @categories = MergeTask.joins(:category).where(categories: { status: :active }).pluck('categories.id', :screenname).uniq

    if params[:category_id]
      @all_state_tasks = MergeTask.includes(page: :category).where('categories.id': params[:category_id])
    else
      @all_state_tasks = MergeTask.includes(page: :category).where(categories: { status: :active })
    end


    if params[:status]
      @merge_tasks = @all_state_tasks.where(status: params[:status])
    else
      @merge_tasks = @all_state_tasks
    end

    @merge_tasks = @merge_tasks.order('pages.category_id').order('pages.aid').page(params[:page]).includes(:last_changed_annotator)
  end

  def show
    return redirect_to merge_tasks_url(category_id: @merge_task.category.id) if @merge_task.merge_attributes.empty?

    @merge_task.merge_attributes.each do |ma|
      return redirect_to(ma) unless ma.completed?
    end

    @tags_by_pid = @merge_task.merge_tags.inject({}) do |grouped, mt|
      grouped[mt.paragraph_id] = [] unless grouped.key? mt.paragraph_id
      grouped[mt.paragraph_id] << mt
      grouped
    end
  end

  def start
    @merge_task.start!(current_annotator)
    redirect_to @merge_task
  end

  def finish
    @merge_task.finish!(current_annotator)
    redirect_to merge_tasks_url(category_id: @merge_task.category.id, status: 'not_started')
  end

  private

  def set_merge_task
    @merge_task = MergeTask.find_by!(id: params[:id])
  end
end
