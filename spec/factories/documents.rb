include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :document do
    title 'Sample document'
    file { fixture_file_upload(
      Rails.root.join('spec', 'support', 'sample.pdf').to_s,
      'application/pdf') }
  end
end
