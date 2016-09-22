FactoryGirl.define do
  factory :report_signing, class: Report::Signing do
    report
    user
  end
end
