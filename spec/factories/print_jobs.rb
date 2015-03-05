FactoryGirl.define do
  factory :print_job do
    cups_id { Faker::Number.number(rand(5) + 1) } # 1 - 99999
    cups_state "MyString"
    fax
  end
end
