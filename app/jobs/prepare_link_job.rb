class PrepareLinkJob < SidekiqJob
  def perform(category_id)
    c = Category.find(category_id)
    c.prepare_link!
  end
end
