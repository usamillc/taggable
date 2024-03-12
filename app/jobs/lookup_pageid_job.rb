class LookupPageidJob < SidekiqJob
  def perform(link_id, _class)
    if _class == :entity_link
      e = EntityLink.find(link_id)
    else
      e = AnnotatedEntityLink.find(link_id)
    end

    e.pageid = LinkAnnotationsHelper::Suggester.instance.lookup_pageid(e.title)
    e.first_sentence = LinkAnnotationsHelper::Suggester.instance.lookup_fs(e.pageid)
    e.save!

    PropagateEntityLinkJob.perform_async(link_id) if _class == :entity_link
  end
end
