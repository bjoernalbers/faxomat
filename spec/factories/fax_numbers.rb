FactoryGirl.define do
  factory :fax_number do
    phone { '0' + Faker::Number.between(1,9).to_s + Faker::Number.number(8).to_s }
  end
end
