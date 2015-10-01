FactoryGirl.define do
  factory :report do
    subject { Faker::Lorem.sentence }
    examination { Faker::Lorem.sentences.join("\n") }
    anamnesis { Faker::Lorem.sentences.join("\n") }
    diagnosis { Faker::Lorem.sentences.join("\n") }
    findings { Faker::Lorem.sentences.join("\n") }
    evaluation { Faker::Lorem.sentences.join("\n") }
    procedure { Faker::Lorem.sentences.join("\n") }
    clinic { Faker::Lorem.sentences.join("\n") }
    user
    patient
    recipient
  end

  factory :api_report, class: API::Report do
    subject               { Faker::Lorem.sentence }
    examination           { Faker::Lorem.sentences.join("\n") }
    anamnesis             { Faker::Lorem.sentences.join("\n") }
    diagnosis             { Faker::Lorem.sentences.join("\n") }
    findings              { Faker::Lorem.sentences.join("\n") }
    evaluation            { Faker::Lorem.sentences.join("\n") }
    procedure             { Faker::Lorem.sentences.join("\n") }
    clinic                { Faker::Lorem.sentences.join("\n") }
    patient_number        { Faker::Number.number(6) }
    patient_first_name    { Faker::Name.first_name }
    patient_last_name     { Faker::Name.last_name }
    patient_date_of_birth { Faker::Date.between(90.years.ago, 20.years.ago) }
    patient_sex           { ['m', 'M', 'w', 'W', 'u', 'U', '', nil ].sample }
    recipient_last_name   { Faker::Name.last_name }
    recipient_fax_number  { '0' + Faker::Number.between(1,9).to_s + Faker::Number.number(8).to_s }

    after(:build) do |report|
      report.username = create(:user).username # Works, but only with `build`!
    end
  end
end
