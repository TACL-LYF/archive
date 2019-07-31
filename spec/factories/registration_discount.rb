FactoryBot.define do
  factory :registration_discount do
    camp
    code { Faker::Lorem.word.upcase }
    discount_type { 1 }
    discount_amount { rand(1..100) }
    redeemed { false }
  end
end
