FactoryGirl.define do
  factory :user do
    username   { Faker::Internet.user_name }
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    title      { Faker::Name.prefix }
    can_release_reports true

    factory :authorized_user

    factory :unauthorized_user do
      can_release_reports false
    end
  end
end
