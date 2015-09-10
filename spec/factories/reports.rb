FactoryGirl.define do
  factory :report do
    subject { Faker::Lorem.sentence }
    content { Faker::Lorem.sentences.join("\n") }
    user
    patient
  end

  factory :api_report, class: API::Report do
    subject               { Faker::Lorem.sentence }
    content               { Faker::Lorem.sentences.join("\n") }
    patient_number        { Faker::Number.number(6) }
    patient_first_name    { Faker::Name.first_name }
    patient_last_name     { Faker::Name.last_name }
    patient_date_of_birth { Faker::Date.between(90.years.ago, 20.years.ago) }
    patient_sex           { ['m', 'M', 'w', 'W', 'u', 'U', '', nil ].sample }

    after(:build) do |report|
      report.username = create(:user).username # Works, but only with `build`!
    end
  end
end
