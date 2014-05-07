FactoryGirl.define do
  factory :job do
    phone '0123456789'
    path '/tmp/letter.pdf'
    patient_first_name 'Chuck'
    patient_last_name 'Norris'
    patient_date_of_birth '1940-03-10'
  end
end
