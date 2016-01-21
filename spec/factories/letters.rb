FactoryGirl.define do
  factory :letter do
    association :report, factory: :verified_report
    user
  end
end
