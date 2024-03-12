class MergeAttributesController < ApplicationController
  before_action :set_merge_attribute
  before_action :merge_allowed_annotator

  def show
    unless @merge_attribute.merge_values.empty?
      return redirect_to(@merge_attribute.merge_values.first)
    end
    @tags_by_pid = @merge_attribute.merge_tags.inject({}) do |grouped, mt|
      grouped[mt.paragraph_id] = [] unless grouped.key? mt.paragraph_id
      grouped[mt.paragraph_id] << mt
      grouped
    end
  end

  def complete
    @merge_attribute.completed!
    redirect_to @merge_attribute.merge_task
  end

  private

  def set_merge_attribute
    @merge_attribute = MergeAttribute.find_by!(id: params[:id])
  end
end
