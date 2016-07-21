FactoryGirl.define do
  factory :delivery do
    document
    printer # TODO: Remove this!
    job_id { Faker::Number.number(7) } # TODO: Remove this!

    factory :active_delivery do
      status { :active }
    end

    factory :completed_delivery do
      status { :completed }
    end

    factory :aborted_delivery do
      status { :aborted }
    end
  end
end
