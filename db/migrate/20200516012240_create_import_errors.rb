class CreateImportErrors < ActiveRecord::Migration[5.2]
  def change
    create_table :import_errors do |t|
      t.string :message
      t.string :error
      t.belongs_to :import, index: true

      t.timestamps
    end
  end
end
