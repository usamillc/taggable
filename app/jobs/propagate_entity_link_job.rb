class PropagateEntityLinkJob < SidekiqJob
  def perform(entity_link_id)
    e = EntityLink.find(entity_link_id)
    e.link_annotation.same_entities.each do |la|
      unless la.entity_links.pluck(:title).include? e.title
        e.dup
          .tap do |e|
            e.link_annotation = la
            e.suggested!
            e.match = false
            e.later_name = false
            e.part_of = false
            e.derivation_of = false
          end
          .save!
      end
    end
  end
end
