FactoryBot.define do
  factory :annotator do
    organization
    sequence(:username) { |n| "user#{n}" }
    screenname { username.capitalize }
    password { '123456' }

    trait :team_ando do
      organization { build(:organization, name: 'TeamANDO') }
    end

    trait :admin do
      username { 'admin' }
      admin { true }
    end
  end
end
