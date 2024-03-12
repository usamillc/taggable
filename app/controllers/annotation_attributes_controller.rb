class AnnotationAttributesController < ApplicationController
  before_action :logged_in_admin

  before_action :set_attribute, except: [:index, :create]

  def index
    @category = Category.find_by(id: params[:category_id])
    @attributes = @category.annotation_attributes
    @attribute = AnnotationAttribute.new
  end

  def create
    @attribute = AnnotationAttribute.new(attribute_params)
    if @attribute.save
      flash[:success] = "新しい属性 #{@attribute.screenname} (#{@attribute.name}) を作成しました。"
      redirect_to attributes_index_path(@attribute.category, focus: @attribute.id)
    else
      flash[:danger] = @attribute.errors.full_messages
      redirect_to attributes_index_path(@attribute.category)
    end
  end

  def edit
  end

  def update
    previous = "#{@attribute.screenname} (#{@attribute.name})"
    if @attribute.update_attributes(attribute_params)
      flash[:success] = "属性 #{previous} の名称を #{@attribute.screenname} (#{@attribute.name}) に変更しました。"
    else
      flash[:danger] = @attribute.errors.full_messages
    end
    redirect_to attributes_index_path(@attribute.category)
  end

  def toggle_linkable
    if @attribute
      @attribute.update_attribute(:linkable, !@attribute.linkable)
      unless @attribute.linkable?
        flash[:danger] = "属性 #{@attribute.screenname} (#{@attribute.name}) をリンク対象から外しました。"
      else
        flash[:success] = "属性 #{@attribute.screenname} (#{@attribute.name}) をリンク対象として表示しました。"
      end
    end
    redirect_to attributes_index_path(@attribute.category)
  end

  def destroy
    if @attribute
      @attribute.update_attribute(:deleted, true)
      flash[:success] = "属性 #{@attribute.screenname} (#{@attribute.name}) を削除しました。"
    end
    redirect_to attributes_index_path(@attribute.category)
  end

  def up_ord
    upper = AnnotationAttribute.find_upper_ord_one(@attribute)
    AnnotationAttribute.swap(@attribute, upper)
    begin
      focus = AnnotationAttribute.find_upper_ord_one(@attribute)
    rescue
      focus = @attribute
    end
    redirect_to attributes_index_path(@attribute.category, focus: focus.id)
  end

  def down_ord
    lower = AnnotationAttribute.find_lower_ord_one(@attribute)
    AnnotationAttribute.swap(@attribute, lower)
    begin
      focus = AnnotationAttribute.find_upper_ord_one(lower)
    rescue
      focus = lower
    end
    redirect_to attributes_index_path(@attribute.category, focus: focus.id)
  end

  private

  def set_attribute
    @attribute = AnnotationAttribute.find_by(id: params[:id])
  end

  def attribute_params
    params.require(:annotation_attribute).permit(:name, :screenname, :category_id, :ord)
  end
end
