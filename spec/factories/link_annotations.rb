FactoryBot.define do
  factory :link_annotation do
    link_task
    merge_tag

    trait :completed do
      status { :completed }
    end

    trait :with_entity_links do
      after(:build) do |la|
        la.entity_links = FactoryBot.build_list(:entity_link, 3)
      end
    end
  end
end
