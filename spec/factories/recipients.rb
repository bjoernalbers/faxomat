FactoryGirl.define do
  factory :recipient do
    sequence :phone do |n|
      "0123456#{n}"
    end
  end
end
