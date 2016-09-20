FactoryGirl.define do
  factory :report_signature, class: Report::Signature do
    report
    user
  end
end
