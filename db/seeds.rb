# make some referral methods
detailed = ["TACL-LYF Counselors", "TACL-LYF Campers and Families",
  "Other Taiwanese Organizations", "Other"]
["TACL-LYF Counselors", "TACL-LYF Campers and Families", "JTASA", "TAP",
  "Other Taiwanese Organizations", "Chinese School", "Newspaper", "Flyers",
  "Other"].each do |method|
  ReferralMethod.create!(name: method, allow_details: detailed.include?(method))
end
referral_methods = ReferralMethod.all

# make some camps
camp = Camp.create!(year: 2016, name: "When LYF Gives You Lemons")
prev_camp = Camp.create!(year: 2015, name: "Circle of LYF")
Camp.create!(year: 2017, name: "To Be Determined")
