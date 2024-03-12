class AddReferenceForImportToTasks < ActiveRecord::Migration[5.2]
  def change
    add_reference :tasks, :import, index: true
  end
end
