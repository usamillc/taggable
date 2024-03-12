class CategoriesController < ApplicationController
  before_action :logged_in_admin, except: [:attributes]
  before_action :logged_in_annotator, only: [:attributes]

  before_action :set_category, except: [:index, :create]

  def index
    @categories = Category.all
    @categories = @categories.active unless params[:show_hidden]
    @categories = @categories.order(created_at: :desc).page(params[:page])

    category_ids = @categories.map &:id
    @task_total      = Category.where(id: category_ids).joins(:tasks).group(:id).count
    @task_completed  = Category.where(id: category_ids).joins(:tasks).where(tasks: { status: :completed }).group(:id).count
    @merge_total     = Category.where(id: category_ids).joins(:merge_tasks).group(:id).count
    @merge_completed = Category.where(id: category_ids).joins(:merge_tasks).where(merge_tasks: { status: :completed }).group(:id).count

    @category = Category.new
    @import = Import.new
  end

  def edit
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      flash[:success] = "カテゴリ ##{@category.id} #{@category.screenname} (#{@category.name}) を作成しました。"
    else
      flash[:danger] = @category.errors.full_messages
    end
    redirect_to categories_path(show_hidden: params[:show_hidden], page: params[:page])
  end

  def update
    if @category.update_attributes(category_params)
      flash[:success] = "カテゴリ ##{@category.id} の名称を #{@category.screenname} (#{@category.name}) に変更しました。"
    else
      flash[:danger] = @category.errors.full_messages
    end
    redirect_to categories_path(show_hidden: params[:show_hidden], page: params[:page])
  end

  def enqueue_prepare_merge
    PrepareMergeJob.perform_async(@category.id)
    redirect_to categories_path(show_hidden: params[:show_hidden], page: params[:page])
  end

  def enqueue_prepare_link
    PrepareLinkJob.perform_async(@category.id)
    redirect_to categories_path(show_hidden: params[:show_hidden], page: params[:page])
  end

  def enqueue_prepare_link_merge
    PrepareLinkMergeJob.perform_async(@category.id)
    redirect_to categories_path(show_hidden: params[:show_hidden], page: params[:page])
  end

  def activate
    if @category
      @category.active!
      flash[:success] = "カテゴリ #{@category.screenname} (#{@category.name}) を表示中に変更しました"
    end
    redirect_to categories_path(show_hidden: params[:show_hidden], page: params[:page])
  end

  def hide
    if @category
      @category.hidden!
      flash[:success] = "カテゴリ #{@category.screenname} (#{@category.name}) を非表示に変更しました"
    end
    redirect_to categories_path(show_hidden: params[:show_hidden], page: params[:page])
  end

  def attributes
    render json: @category.annotation_attributes
  end

  def mergeable_count
    @count = @category.mergeable_count
    render partial: 'count'
  end

  def linkable_count
    @count = @category.linkable_count
    render partial: 'count'
  end

  def link_mergeable_count
    @count = @category.link_mergeable_count
    render partial: 'count'
  end

  private

  def set_category
    @category = Category.find_by(id: params[:id])
  end

  def category_params
    params.require(:category).permit(:screenname, :name, :def_link)
  end
end
