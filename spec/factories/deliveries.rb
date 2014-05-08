FactoryGirl.define do
  factory :delivery do
    sequence :print_job_id
    print_job_state 'unknown'
    fax
  end
end
