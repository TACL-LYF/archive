require 'faker'

FactoryGirl.define do
  factory :camp do
    year 2016
    name { Faker::Lorem.words((4..10).to_a.sample) }
  end
end
