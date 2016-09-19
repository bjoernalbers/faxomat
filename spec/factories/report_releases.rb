FactoryGirl.define do
  factory :report_release, class: Report::Release do
    report
    user
  end
end
