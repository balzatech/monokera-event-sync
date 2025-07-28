FactoryBot.define do
  factory :order do
    customer_id { rand(1..100) }
    product_name { Faker::Commerce.product_name }
    quantity { rand(1..10) }
    price { Faker::Commerce.price(range: 10.0..1000.0) }
    status { 'pending' }
  end
end