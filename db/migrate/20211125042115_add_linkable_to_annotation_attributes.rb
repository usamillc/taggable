class AddLinkableToAnnotationAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :annotation_attributes, :linkable, :boolean, default: true
  end
end
