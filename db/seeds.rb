# make referral methods
detailed = ["TACL-LYF Counselors", "Referred by a TACL-LYF Camper",
  "Other Taiwanese Organizations", "Other"]
["TACL-LYF Counselors", "Referred by a TACL-LYF Camper", "JTASA", "TAP",
  "Other Taiwanese Organizations", "Chinese School", "Newspaper", "Flyers",
  "Facebook", "Other"].each do |m|
  ReferralMethod.find_or_create_by!(name: m) do |rm|
    rm.allow_details = detailed.include?(m)
  end
end

# make current camp
Camp.find_or_create_by!(year: 2017) do |c|
  c.name = "To Be Determined"
  c.registration_fee = 680
  c.sibling_discount = 40
  c.shirt_price = 15
end

# make admin user for ActiveAdmin
AdminUser.find_or_create_by!(email: 'admin@example.com') do |au|
  au.password = 'password'
  au.password_confirmation = 'password'
end
