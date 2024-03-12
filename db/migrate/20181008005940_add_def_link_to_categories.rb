class AddDefLinkToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :def_link, :string
  end
end
