class Donation < ApplicationRecord
  validates :first_name, :last_name, :email, :address, :city, :state,
            :zip, presence: true
  validates :email, length: { maximum: 255 }, format: VALID_EMAIL_REGEX
  validates :state, length: { is: 2 }
  validates :zip, length: { minimum: 5 }
  validates :amount, presence: true, numericality: { greater_than: 0 },
            format: { with: /\A\d+(?:\.\d{0,2})?\z/ }
  validates :stripe_last_four, length: { is: 4 },
            numericality: { only_integer: true }, allow_blank: true

  before_create :process_payment

  attr_accessor :other_amount, :stripe_token

  private
    def reject_if_amex
      token = Stripe::Token.retrieve(stripe_token)
      if token.card.brand == "American Express"
        raise Exceptions::AmexError
      end
    end

    def process_payment
      reject_if_amex
      total = (amount*100).to_i
      desc = "Donation Payment from #{first_name} #{last_name} (#{email})"
      charge_obj = Stripe::Charge.create(source: stripe_token, amount: total,
                                         description: desc, currency: 'usd')
      self.stripe_charge_id = charge_obj.id
      self.stripe_brand = charge_obj.source.brand
      self.stripe_last_four = charge_obj.source.last4
    end
end
