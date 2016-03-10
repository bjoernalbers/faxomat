FactoryGirl.define do
  factory :patient do
    first_name    { Faker::Name.first_name }
    last_name     { Faker::Name.last_name }
    date_of_birth { Faker::Date.between(20.years.ago, 90.years.ago) }
    title         { [ nil, Faker::Name.prefix ].sample }
    suffix        { [ nil, Faker::Name.suffix ].sample }
    sex           { [ nil, 0, 1 ].sample }
    number        { Faker::Number.number(6) }
  end
end
