FactoryGirl.define do
  factory :referral_method do
    name { Faker::Lorem.words(rand(1..5)) }
    allow_details { [true, false].sample }
    details_field_label { Faker::Lorem.words(rand(1..3)) }
  end
end
