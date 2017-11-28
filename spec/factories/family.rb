require 'faker'
Faker::Config.locale = 'en-US'

FactoryBot.define do
  factory :family do
    primary_parent_first_name { Faker::Name.first_name }
    primary_parent_last_name { Faker::Name.last_name }
    primary_parent_email { Faker::Internet.safe_email }
    primary_parent_phone_number { Faker::PhoneNumber.area_code + Faker::PhoneNumber.exchange_code + Faker::PhoneNumber.subscriber_number }
    secondary_parent_first_name { Faker::Name.first_name }
    secondary_parent_last_name { [primary_parent_last_name, Faker::Name.last_name].sample }
    secondary_parent_email { Faker::Internet.safe_email }
    secondary_parent_phone_number { Faker::PhoneNumber.area_code + Faker::PhoneNumber.exchange_code + Faker::PhoneNumber.subscriber_number }
    street { Faker::Address.street_address }
    suite { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }
  end
end
