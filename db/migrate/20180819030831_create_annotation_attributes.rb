class CreateAnnotationAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :annotation_attributes do |t|
      t.belongs_to :category, index: true
      t.string :name
      t.string :screenname
      t.string :tag

      t.timestamps
    end
  end
end
