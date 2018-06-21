FactoryGirl.define do
  factory :printer do
    name { "Printer-#{Faker::Number.number(5)}" }
    label { Faker::StarWars.droid }

    factory :fax_printer, class: FaxPrinter do
      dialout_prefix { Faker::Number.digit }
    end

    factory :paper_printer, class: PaperPrinter do
      dialout_prefix { nil }
    end

    factory :hylafax_printer, class: HylafaxPrinter do
    end
  end
end
