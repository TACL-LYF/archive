class RegistrationDiscount < ApplicationRecord
  belongs_to :camp, inverse_of: :registration_discounts
  belongs_to :registration_payment, inverse_of: :registration_discount, optional: true

  validates :camp, :code, :discount_percent, presence: true
  validates :code, uniqueness: { scope: :camp_id }
  validates :redeemed, inclusion: { in: [true, false] }
  validates :discount_percent, numericality: { only_integer: true },
                               inclusion: { in: 1..100 }
  validates :registration_payment_id, presence: true, if: :redeemed

  before_validation { self.code = code.gsub(/\s+/, '').upcase unless code.nil? }
  before_save :toggle_redeem_if_payment_exists

  def self.get(code)
    where(code: normalize_code(code), redeemed: false).take
  end

  protected
    def toggle_redeem_if_payment_exists
      if self.registration_payment
        self.redeemed = true
      else
        self.redeemed = false
      end
    end

  private
    def self.normalize_code(code)
      code ||= ""
      code.gsub(/\s+/, '').upcase
    end
end
