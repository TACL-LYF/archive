require 'faker'

FactoryBot.define do
  factory :camp do
    year { 2016 }
    name { Faker::Lorem.words(rand(4..10)) }
    camp_start_date { Date.new(2016,6,20) }
    camp_end_date { Date.new(2016,6,26) }
    registration_open_date { Date.new(2015,12,1) }
    registration_late_date { Date.new(2016,5,1) }
    registration_close_date { Date.new(2016,5,15) }
    registration_fee { 680.00 }
    sibling_discount { 40.00 }
    registration_late_fee { 40.00 }
    shirt_price { 15.00 }
    waitlist_starts_after { 100 }
  end
end
