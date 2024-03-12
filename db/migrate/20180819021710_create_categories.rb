class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :screenname

      t.timestamps
    end

    change_table :pages do |t|
      t.belongs_to :category, index: true
    end
  end
end
