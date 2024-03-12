class AddPasswordDigestToAnnotators < ActiveRecord::Migration[5.2]
  def change
    add_column :annotators, :password_digest, :string
    add_column :annotators, :remember_digest, :string
    rename_column :annotators, :name, :username
  end
end
