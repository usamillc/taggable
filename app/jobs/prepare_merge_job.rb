class PrepareMergeJob < SidekiqJob
  def perform(category_id)
    c = Category.find(category_id)
    c.prepare_merge!
  end
end
