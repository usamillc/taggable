class AddDeletedToAnnotators < ActiveRecord::Migration[5.2]
  def change
    add_column :annotators, :deleted, :boolean, default: false
  end
end
