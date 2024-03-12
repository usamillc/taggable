class AddReferenceForOrganizationToTasks < ActiveRecord::Migration[5.2]
  def change
    add_reference :tasks, :organization, index: true
  end
end
