class MergeValuesController < ApplicationController
  before_action :set_merge_value
  before_action :merge_allowed_annotator

  def show
    @tags_by_pid = @merge_value.merge_tags.inject({}) do |grouped, mt|
      grouped[mt.paragraph_id] = [] unless grouped.key? mt.paragraph_id
      grouped[mt.paragraph_id] << mt
      grouped
    end
  end

  def complete
    @merge_value.completed!
    redirect_to @merge_value.merge_attribute
  end

  private

  def set_merge_value
    @merge_value = MergeValue.find_by(id: params[:id])
  end
end
