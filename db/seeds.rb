# make some referral methods
detailed = ["TACL-LYF Counselors", "TACL-LYF Campers and Families",
  "Other Taiwanese Organizations", "Other"]
["TACL-LYF Counselors", "TACL-LYF Campers and Families", "JTASA", "TAP",
  "Other Taiwanese Organizations", "Chinese School", "Newspaper", "Flyers",
  "Other"].each do |method|
  ReferralMethod.create!(name: method, allow_details: detailed.include?(method))
end

# make some camps
Camp.create!(year: 2016, name: "When LYF Gives You Lemons",
  registration_fee: 600, sibling_discount: 40, shirt_price: 15)
Camp.create!(year: 2015, name: "Circle of LYF",
  registration_fee: 500, sibling_discount: 40, shirt_price: 15)
camp = Camp.create!(year: 2017, name: "To Be Determined",
  registration_fee: 680, sibling_discount: 40, shirt_price: 15)

# make some discounts
camp.registration_discounts.create!(code: "ANNIE", discount_percent: 20)
camp.registration_discounts.create!(code: "BRIAN", discount_percent: 10)
