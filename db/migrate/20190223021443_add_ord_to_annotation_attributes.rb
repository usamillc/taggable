class AddOrdToAnnotationAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :annotation_attributes, :ord, :integer, defaul: 0
    AnnotationAttribute.update_all(ord: 0)
    add_index :annotation_attributes, [:ord, :id]
  end
end
