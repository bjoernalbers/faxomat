FactoryGirl.define do
  factory :print_job do
    number { Faker::Number.number(7) }
    #fax_number { '0' + Faker::Number.between(1,9).to_s + Faker::Number.number(8).to_s }
    printer
  end
end
