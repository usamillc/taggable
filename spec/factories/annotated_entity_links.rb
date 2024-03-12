FactoryBot.define do
  factory :annotated_entity_link do
    link_merge_annotation { build(:link_merge_annotation) }
    title { 'example' }
    pageid { 1 }
    match { true }

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end
  end
end
