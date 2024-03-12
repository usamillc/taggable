class CreateLinkTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :link_tasks do |t|
      t.belongs_to :page, index: true
      t.belongs_to :annotator
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
