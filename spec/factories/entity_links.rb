FactoryBot.define do
  factory :entity_link do
    link_annotation { build(:link_annotation) }
    title { 'example' }
    pageid { 1 }

    trait :match do
      match { true }
    end

    trait :later_name do
      later_name { true }
    end

    trait :part_of do
      part_of { true }
    end

    trait :derivation_of do
      derivation_of { true }
    end
  end
end
