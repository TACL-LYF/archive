# make referral methods
detailed = ["TACL-LYF Counselors", "TACL-LYF Campers and Families",
  "Other Taiwanese Organizations", "Other"]
["TACL-LYF Counselors", "TACL-LYF Campers and Families", "JTASA", "TAP",
  "Other Taiwanese Organizations", "Chinese School", "Newspaper", "Flyers",
  "Other"].each do |method|
  ReferralMethod.create!(name: method, allow_details: detailed.include?(method))
end

# make current camp
Camp.create!(year: 2017, name: "To Be Determined",
  registration_fee: 680, sibling_discount: 40, shirt_price: 15)
