class CreateParagraphs < ActiveRecord::Migration[5.2]
  def change
    create_table :paragraphs do |t|
      t.belongs_to :page, index: true
      t.string :body
      t.string :tagged
      t.string :no_tag
      t.string :hexdigest

      t.timestamps
    end
  end
end
