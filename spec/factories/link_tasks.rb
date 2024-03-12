FactoryBot.define do
  factory :link_task do
    page

    trait :with_annotations do
      after(:build) do |task|
        task.link_annotations = FactoryBot.build_list(:link_annotation, 5)
        task.link_annotations += FactoryBot.build_list(:link_annotation, 5, :completed)
      end
    end

    trait :with_completed_annotations do
      after(:build) do |task|
        task.link_annotations += FactoryBot.build_list(:link_annotation, 5, :completed)
      end
    end
  end
end
