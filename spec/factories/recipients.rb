FactoryGirl.define do
  factory :recipient do
    phone { '0' + Faker::PhoneNumber.phone_number }
  end
end
