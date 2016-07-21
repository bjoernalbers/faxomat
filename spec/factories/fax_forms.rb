include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :fax_form do
    title { Faker::Lorem.sentence }
    phone { '0' + Faker::Number.between(1,9).to_s + Faker::Number.number(8).to_s }
    document { fixture_file_upload(
      Rails.root.join('spec', 'support', 'sample.pdf').to_s,
      'application/pdf') }
    association :printer, factory: :fax_printer
  end
end
