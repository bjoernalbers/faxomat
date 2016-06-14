FactoryGirl.define do
  factory :address do
    street { Faker::Address.street_address }
    zip    { Faker::Address.zip }
    city   { Faker::Address.city }
  end
end
