class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.string :name

      t.timestamps
    end

    add_reference :annotators, :organization, index: true
  end
end
