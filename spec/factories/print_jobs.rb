FactoryGirl.define do
  factory :print_job do
    cups_job_id { Faker::Number.number(rand(5) + 1) } # 1 - 99999
    cups_job_status nil
    fax

    factory :active_print_job do
      cups_job_status nil
    end

    factory :completed_print_job do
      cups_job_status 'completed'
    end

    factory :aborted_print_job do
      cups_job_status 'aborted'
    end
  end
end
