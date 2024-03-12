FactoryBot.define do
  factory :annotation_attribute do
    category
    sequence(:name) { |n| "kana#{n}" }
    screenname { name.capitalize }
    ord { 0 }
    linkable { true }

    trait :deleted do
      deleted { true }
    end

    trait :city do
      name { 'city' }
      screenname { '都市名' }
    end
  end
end
