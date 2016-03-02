FactoryGirl.define do
  factory :template do
    title { Faker::Company.name }
    short_title { Faker::Company.name }
    subtitle { Faker::Company.catch_phrase }
    slogan { Faker::Company.bs }
    address { Faker::Address.street_address }
    zip { Faker::Address.zip }
    city { Faker::Address.city }
    phone { Faker::PhoneNumber.phone_number }
    fax { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.safe_email }
    homepage { Faker::Internet.domain_name }
    owners { Faker::Name.name }
  end
end
