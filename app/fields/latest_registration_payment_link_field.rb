require "administrate/field/base"

class LatestRegistrationPaymentLinkField < Administrate::Field::HasMany
  def to_s
    data.last
  end
end
