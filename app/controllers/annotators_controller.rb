class AnnotatorsController < ApplicationController
  before_action :logged_in_admin, except: [:edit, :update]
  before_action :logged_in_annotator, only: [:edit, :update]
  before_action :set_annotator, only: [:edit, :update, :destroy, :toggle_admin]

  def index
    @annotators = current_annotator.organization.annotators.page(params[:page])
  end

  def new
    @annotator = Annotator.new
  end

  def create
    @annotator = Annotator.new(annotator_params)
    if @annotator.save
      flash[:success] = "新しいユーザー #{@annotator.username} (#{@annotator.screenname}) を作成しました。"
      redirect_to annotators_path
    else
      flash.now[:danger] = @annotator.errors.full_messages
      render 'new'
    end
  end

  def edit
  end

  def update
    if @annotator.update_attributes(annotator_params)
      flash[:success] = 'ユーザー情報を更新しました。'
      redirect_to tasks_path
    else
      flash.now[:danger] = @annotator.errors.full_messages
      render 'edit'
    end
  end

  def destroy
    if @annotator
      @annotator.update_attribute(:deleted, true)
      flash[:success] = "ユーザー #{@annotator.username} (#{@annotator.screenname}) を削除しました。"
    end
    redirect_to annotators_path
  end

  def toggle_admin
    if @annotator
      @annotator.update_attribute(:admin, !@annotator.admin)
    end
    redirect_to annotators_path
  end

  private

  def set_annotator
    @annotator = Annotator.find_by(id: params[:id])
  end

  def annotator_params
    params.require(:annotator).permit(:username, :screenname, :password, :password_confirmation, :organization_id)
  end
end
