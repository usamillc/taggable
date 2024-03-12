class RemoveTaggedFromParagraphs < ActiveRecord::Migration[5.2]
  def change
    remove_column :paragraphs, :tagged
    remove_column :paragraphs, :hexdigest
  end
end
