class CreateLinkMergeTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :link_merge_tasks do |t|
      t.belongs_to :page, index: { unique: true }
      t.belongs_to :annotator
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
