require 'faker'

FactoryGirl.define do
  factory :camp do
    year 2016
    name { Faker::Lorem.words(rand(4..10)) }
  end
end
