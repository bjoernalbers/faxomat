FactoryGirl.define do
  factory :printer do
    name { "Printer-#{Faker::Number.number(5)}" }
    label { Faker::StarWars.droid }
    dialout_prefix { [0, 1, 2, 3, nil].sample }

    factory :fax_printer do
      is_fax_printer true
    end
  end
end
