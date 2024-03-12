class CreateAnnotators < ActiveRecord::Migration[5.2]
  def change
    create_table :annotators do |t|
      t.string :name
      t.string :screenname
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
