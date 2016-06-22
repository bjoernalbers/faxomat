FactoryGirl.define do
  factory :report do
    #study do
    #  studies = <<-EOT
    #    Mammographie beidseits mit Tomosynthese beidseits
    #    MRT der HWS
    #    MRT des Kopfes nativ mit arterieller Angiographie und computergestützter Rekonstruktion
    #    MRT Becken mit computergesteuerter Rekonstruktion
    #    MRT des rechten Kniegelenkes nativ
    #    MRT des rechten Kniegelenkes
    #    MRT der LWS nativ
    #    CT der LWS ab L2 und des Os sacrum in Multislicespiraltechnik, mit Kontrastmittel und computergestützter Rekonstruktion
    #    CCT nativ in Multislicespiraltechnik mit computergestützter Rekonstruktion
    #    MRT des Kopfes nativ, mit Kontrastmittelgabe, mit arterieller und venöser Gefäßdarstellung und computergestützter Rekonstruktion
    #    MRT rechtes OSG nativ und mit Kontrastmittel
    #    Abklärungsbericht
    #    MRT des rechten Kniegelenkes
    #    CT der LWS in Multislicespiraltechnik von L1 bis S1 mit computergesteuerter Rekonstruktion
    #    Mammographie beidseits in 2 Ebenen
    #  EOT
    #  studies.split("\n").map(&:strip).sample
    #end
    study { Faker::Lorem.sentence }
    study_date { Faker::Date.between(2.days.ago, Date.today) }
    anamnesis { Faker::Lorem.sentences.join("\n") }
    diagnosis { Faker::Lorem.sentences.join("\n") }
    findings { Faker::Lorem.sentences.join("\n") }
    evaluation { Faker::Lorem.sentences(10).join("\n") }
    procedure { Faker::Lorem.sentences.join("\n") }
    clinic { Faker::Lorem.sentences.join("\n") }
    user
    patient
    recipient

    factory :pending_report do
      verified_at { nil }
      canceled_at { nil }
    end

    factory :verified_report do
      verified_at { Time.zone.now }
      canceled_at { nil }
    end

    factory :canceled_report do
      verified_at { Time.zone.now }
      canceled_at { Time.zone.now }
    end
  end

  factory :api_report, class: API::Report do
    recipient_salutation  { ['Hallo,', 'Moin,', 'Hi,', nil].sample }
    study                 { Faker::Lorem.sentence }
    study_date            { Faker::Date.between(2.days.ago, Date.today) }
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
    recipient_street      { Faker::Address.street_address }
    recipient_zip         { Faker::Address.zip }
    recipient_city        { Faker::Address.city }

    after(:build) do |report|
      report.username = create(:user).username # Works, but only with `build`!
    end
  end
end
