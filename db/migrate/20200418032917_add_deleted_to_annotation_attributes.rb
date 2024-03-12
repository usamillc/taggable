class AddDeletedToAnnotationAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :annotation_attributes, :deleted, :boolean, default: false
  end
end
