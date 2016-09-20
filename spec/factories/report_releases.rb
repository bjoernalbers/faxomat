FactoryGirl.define do
  factory :report_release, class: Report::Release do
    report
    user

    factory :uncanceled_report_release do
      canceled_at { nil }
    end

    factory :canceled_report_release do
      canceled_at { 5.minutes.ago }
    end
  end
end
