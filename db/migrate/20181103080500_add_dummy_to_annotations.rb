class AddDummyToAnnotations < ActiveRecord::Migration[5.2]
  def change
    add_column :annotations, :dummy, :boolean, default: false
  end
end
