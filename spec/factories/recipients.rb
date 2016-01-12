FactoryGirl.define do
  factory :recipient do
    first_name     { Faker::Name.first_name }
    last_name      { Faker::Name.last_name }
    title          { [ nil, Faker::Name.prefix ].sample }
    salutation     { [ nil, 'Hallo Du,', 'Hurra!' ].sample }
    suffix         { [ nil, Faker::Name.suffix ].sample }
    address        { Faker::Address.street_address }
    city           { Faker::Address.city }
    zip            { Faker::Address.zip }
    fax_number     { '0' + Faker::Number.between(1,9).to_s + Faker::Number.number(8).to_s }
  end
end
