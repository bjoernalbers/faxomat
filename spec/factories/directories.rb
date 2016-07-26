FactoryGirl.define do
  factory :directory do
    description do
      [
        %w(Krankenhaus Klinikum Hospital).sample,
        Faker::Address.city
      ].join(' ')
    end
    path { Dir.mktmpdir(nil, Rails.root.join('tmp')) }
  end
end
