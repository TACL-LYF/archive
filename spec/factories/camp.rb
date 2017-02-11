require 'faker'

FactoryGirl.define do
  factory :camp do
    year 2016
    name { Faker::Lorem.words(rand(4..10)) }
    shirt_price "15.00"
    registration_fee "680.00"
    sibling_discount "40.00"
  end
end
