class CreateRevisions < ActiveRecord::Migration[5.2]
  def change
    create_table :revisions do |t|
      t.string :action
      t.boolean :undone, default: false
      t.belongs_to :annotation, index: true
      t.belongs_to :annotator
      t.belongs_to :page, index: true

      t.timestamps
    end
  end
end
