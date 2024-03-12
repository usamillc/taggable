class ChangeRevisionsAssociation < ActiveRecord::Migration[5.2]
  def change
    remove_reference :revisions, :page
    add_reference :revisions, :task, index: true
  end
end
