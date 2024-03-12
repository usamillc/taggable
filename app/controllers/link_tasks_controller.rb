class LinkTasksController < ApplicationController
  before_action :logged_in_annotator
  before_action :set_task, only: [:show, :start, :finish]

  def index
    @categories = LinkTask.joins(:category).where(categories: { status: :active }).pluck('categories.id', :screenname).uniq

    if params[:category_id]
      @all_state_tasks = LinkTask.includes(page: :category).where('categories.id': params[:category_id])
    else
      @all_state_tasks = LinkTask.includes(page: :category).where(categories: { status: :active })
    end

    if params[:status]
      @tasks = @all_state_tasks.where(status: params[:status])
    else
      @tasks = @all_state_tasks
    end

    @tasks = @tasks.order('pages.category_id').order('pages.aid').page(params[:page]).includes(:last_changed_annotator)
  end

  def show
    la = @task.link_annotations.incomplete.first
    if la
      return redirect_to link_annotation_url(la.id)
    end
    # show completed
  end

  def start
    @task.start!(current_annotator)
    redirect_to @task
  end

  def finish
    @task.finish!(current_annotator)
    redirect_to link_tasks_url(category_id: @task.category.id)
  end

  private

  def set_task
    @task = LinkTask.find_by!(id: params[:id])
  end
end
