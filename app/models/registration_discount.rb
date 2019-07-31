class RegistrationDiscount < ApplicationRecord
  belongs_to :camp, inverse_of: :registration_discounts
  belongs_to :registration_payment, inverse_of: :registration_discount, optional: true

  validate :discount_amount_within_range
  validates :camp, :code, :discount_type, :discount_amount, :description,
    presence: true
  validates :code, uniqueness: { scope: :camp_id }
  validates :redeemed, inclusion: { in: [true, false] }
  validates :registration_payment_id, presence: true, if: :redeemed

  enum discount_type: { percent: 1, fixed_amount: 2 }, _prefix: true

  before_validation { self.code = code.gsub(/\s+/, '').upcase unless code.nil? }
  before_save :toggle_redeem_if_payment_exists

  def self.get(code)
    where(code: normalize_code(code), redeemed: false).take
  end

  private
    def toggle_redeem_if_payment_exists
      if self.registration_payment && self.registration_payment.paid
        self.redeemed = true
      else
        self.redeemed = false
      end
    end

    def self.normalize_code(code)
      code ||= ""
      code.gsub(/\s+/, '').upcase
    end

    # custom validation method
    def discount_amount_within_range
      if self.discount_type_percent?
        unless self.discount_amount > 0 && self.discount_amount <= 100
          errors.add(:discount_amount, :invalid_discount_percent,
          message: "must be between 0 and 100 if discount_type is percent")
        end
      elsif self.discount_type_fixed_amount?
        unless self.discount_amount > 0
          errors.add(:discount_amount, :invalid_discount_amount,
          message: "most be greater than 0")
        end
      end
    end
end
