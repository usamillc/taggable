FactoryBot.define do
  factory :merge_attribute do
    merge_task
    name { 'kana' }
    screenname { 'ふりがな' }

    trait :completed do
      status { :completed }
    end
  end
end
