require "administrate/field/base"

class StripeTokenField < Administrate::Field::Base
  def to_s
    data
  end

  def to_link
    CreditCardService.get_link(data)
  end
end
