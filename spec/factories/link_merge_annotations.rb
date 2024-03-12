FactoryBot.define do
  factory :link_merge_annotation do
    link_merge_task
    merge_tag

    trait :completed do
      status { :completed }
    end

    trait :with_approved_links do
      after(:build) do |lma|
        lma.annotated_entity_links = FactoryBot.build_list(:annotated_entity_link, 3, :approved)
      end
    end

    trait :with_rejected_links do
      after(:build) do |lma|
        lma.annotated_entity_links = FactoryBot.build_list(:annotated_entity_link, 3, :rejected)
      end
    end

    trait :with_approved_and_rejected_links do
      after(:build) do |lma|
        lma.annotated_entity_links = FactoryBot.build_list(:annotated_entity_link, 2, :approved)
        lma.annotated_entity_links += FactoryBot.build_list(:annotated_entity_link, 2, :rejected)
      end
    end

    trait :with_conflicted_links do
      after(:build) do |lma|
        lma.annotated_entity_links = FactoryBot.build_list(:annotated_entity_link, 3)
      end
    end
  end
end
