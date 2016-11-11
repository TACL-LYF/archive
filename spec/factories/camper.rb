require 'faker'

FactoryGirl.define do
  factory :camper do
    family
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    gender { [:male, :female].sample }
    birthdate { Faker::Date.between(18.years.ago, 9.years.ago) }
    email { Faker::Internet.safe_email }
    medical_conditions_and_medication "N/A"
    diet_and_food_allergies "N/A"
    status :active
  end
end
