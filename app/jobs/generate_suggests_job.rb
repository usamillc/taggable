class GenerateSuggestsJob < SidekiqJob
  def perform(link_annotation_id)
    l = LinkAnnotation.find(link_annotation_id)
    l.generate_suggests!
  end
end
