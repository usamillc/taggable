class AddEneidToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :ene_id, :string
  end
end
