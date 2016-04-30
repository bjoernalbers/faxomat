FactoryGirl.define do
  factory :template do
    title { Faker::Company.name }
    short_title { Faker::Company.name }
    subtitle { Faker::Company.catch_phrase }
    slogan { Faker::Company.bs }
    return_address do
      [ Faker::Company.name,
        Faker::Address.street_address,
        Faker::Address.city ].join(' · ')
    end
    contact_infos do
      [ Faker::PhoneNumber.phone_number,
        Faker::Internet.safe_email,
        Faker::Internet.domain_name ].join(' · ')
    end
    owners { Faker::Name.name }
  end
end
