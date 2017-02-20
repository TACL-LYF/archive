require "administrate/field/base"

class ReferrerField < Administrate::Field::Base
  def to_s
    data.reduce("") { |memo, r|
      memo + r.referral_method.name + (r.details.blank? ? "" : " (#{r.details})") + ", "
    }.chomp(", ")
  end
end
