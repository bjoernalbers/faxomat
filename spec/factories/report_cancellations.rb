FactoryGirl.define do
  factory :report_cancellation, class: Report::Cancellation do
    association :report, factory: :verified_report
    user
  end
end
