FactoryGirl.define do
  factory :recipient do
    first_name     { Faker::Name.first_name }
    last_name      { Faker::Name.last_name }
    title          { Faker::Name.prefix }
    suffix         { Faker::Name.suffix }
    salutation     { [ 'Hallo Du,', 'Hurra!' ].sample }
    fax_number     { '0' + Faker::Number.between(1,9).to_s + Faker::Number.number(8).to_s }
    address
  end
end
