require 'faker'

FactoryGirl.define do
  factory :last_day_purchase do
    first_name { Faker::Name.last_name }
    last_name { Faker::Name.first_name }
    email { Faker::Internet.safe_email }
    phone { Faker::PhoneNumber.area_code + Faker::PhoneNumber.exchange_code + Faker::PhoneNumber.subscriber_number }
    address  { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }
    amount "680.00"
  end
end
