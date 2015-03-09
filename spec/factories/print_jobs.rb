FactoryGirl.define do
  factory :print_job do
    cups_id { Faker::Number.number(rand(5) + 1) } # 1 - 99999
    cups_status nil
    fax

    factory :active_print_job do
      cups_status nil
    end

    factory :completed_print_job do
      cups_status 'completed'
    end

    factory :aborted_print_job do
      cups_status 'aborted'
    end
  end
end
