class CreateMergeTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :merge_tasks do |t|
      t.belongs_to :page, index: true
      t.belongs_to :annotator, index: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
