FactoryBot.define do
  factory :task do
    page
    organization

    trait :completed do
      status { :completed }
    end
  end
end
