FactoryGirl.define do
  factory :print_job do
    fax_number { '0' + Faker::Number.between(1,9).to_s + Faker::Number.number(8).to_s }
    association :printer, factory: :fax_printer
    document

    factory :print_job_with_job_id do
      job_id { Faker::Number.number(7) }

      factory :active_print_job do
        status { :active }
      end

      factory :completed_print_job do
        status { :completed }
      end

      factory :aborted_print_job do
        status { :aborted }
      end
    end
  end
end
