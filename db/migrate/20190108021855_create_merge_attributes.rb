class CreateMergeAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :merge_attributes do |t|
      t.belongs_to :merge_task, index: true
      t.string :name
      t.string :screenname
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
