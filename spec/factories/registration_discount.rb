FactoryBot.define do
  factory :registration_discount do
    camp
    code { Faker::Lorem.word.upcase }
    discount_percent { rand(1..100) }
    redeemed false
  end
end
