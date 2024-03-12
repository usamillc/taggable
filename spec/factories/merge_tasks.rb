FactoryBot.define do
  factory :merge_task do
    trait :with_annotator do
      last_changed_annotator { build(:annotator) }
    end

    trait :in_progress do
      status { :in_progress }
    end

    trait :completed do
      status { :completed }
    end

    transient do
      category { nil }
    end

    page { build(:page, category: category.present? ? category : build(:category) ) }
  end
end
