FactoryBot.define do
  factory :category do
    sequence :name do |n|
      "test#{n}"
    end

    screenname { name.capitalize }

    trait :whs do
      name { 'World Heritage Site' }
      screenname { '世界遺産' }
      def_link { 'https://www.google.com' }
    end
  end
end
