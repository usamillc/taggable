class CreateAnnotations < ActiveRecord::Migration[5.2]
  def change
    create_table :annotations do |t|
      t.belongs_to :paragraph, index: true
      t.belongs_to :annotator, index: true
      t.belongs_to :annotation_attribute, index: true
      t.integer :start_offset
      t.integer :end_offset
      t.string :value
      t.boolean :reflected, default: false
      t.boolean :deleted, default: false

      t.timestamps
    end
  end
end
