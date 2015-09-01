FactoryGirl.define do
  factory :report do
    subject { Faker::Lorem.sentence }
    content { Faker::Lorem.sentences.join("\n") }
    user
  end
end
