FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    address { Faker::Address.full_address }
    orders_count { 0 }

    trait :with_orders do
      orders_count { rand(1..10) }
    end

    trait :with_many_orders do
      orders_count { rand(50..200) }
    end

    trait :without_orders do
      orders_count { 0 }
    end
  end
end