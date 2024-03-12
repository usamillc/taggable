FactoryBot.define do
  factory :annotation do
    task_paragraph
    annotator
    annotation_attribute
    value { "test" }
    start_offset { 0 }
    end_offset { start_offset + value.length }

    trait :deleted do
      deleted { true }
    end
  end
end
