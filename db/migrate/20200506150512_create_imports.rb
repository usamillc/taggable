class CreateImports < ActiveRecord::Migration[5.2]
  def change
    create_table :imports do |t|
      t.belongs_to :category, index: true
      t.belongs_to :annotator, index: true
      t.integer :tasks_to_import

      t.timestamps
    end
  end
end
