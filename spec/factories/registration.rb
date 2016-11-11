require 'faker'

FactoryGirl.define do
  factory :registration do
    camper
    camp
    grade { rand(3..10) }
    shirt_size { %w[x_small small medium large x_large xx_large].sample }
    bus { [true, false].sample }
    city { camper.family.city }
    state { camper.family.state }
    waiver_signature { camper.family.primary_parent }
    waiver_date { Time.zone.now }
  end
end
