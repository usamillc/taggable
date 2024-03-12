class MakeAnnotatorOptional < ActiveRecord::Migration[5.2]
  def change
    remove_reference :tasks, :annotator
    add_reference :tasks, :annotator, index: true, optional: true
  end
end
