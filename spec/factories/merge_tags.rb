FactoryBot.define do
  factory :merge_tag do
    merge_value
    paragraph
    start_offset { 5 }
    end_offset { start_offset + 5 }

    trait :approved do
      status { 'approved' }
    end

    trait :deleted do
      status { 'deleted' }
    end
  end
end
