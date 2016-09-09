FactoryGirl.define do
  factory :report_verification, class: Report::Verification do
    report
    user
  end
end
