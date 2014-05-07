FactoryGirl.define do
  factory :fax do
    path '/tmp/letter.pdf'
    recipient
    patient
  end
end
