class ChangeAnnotationsToBelongsToTaskParagraph < ActiveRecord::Migration[5.2]
  def change
    remove_reference :annotations, :paragraph
    add_reference :annotations, :task_paragraph, index: true
  end
end
