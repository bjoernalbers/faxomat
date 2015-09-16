FactoryGirl.define do
  factory :recipient do
    first_name     { Faker::Name.first_name }
    last_name      { Faker::Name.last_name }
    title          { [ nil, Faker::Name.prefix ].sample }
    suffix         { [ nil, Faker::Name.suffix ].sample }
    sex            { [ nil, 0, 1 ].sample }
    address        { Faker::Address.street_address }
    city           { Faker::Address.city }
    zip            { Faker::Address.zip }
  end
end
