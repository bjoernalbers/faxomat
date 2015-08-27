FactoryGirl.define do
  factory :fax_number do
    phone { '0' + Faker::PhoneNumber.phone_number }
  end
end
