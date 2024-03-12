class AddVersionToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :version, :string
  end
end
