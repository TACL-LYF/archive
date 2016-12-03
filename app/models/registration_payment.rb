class RegistrationPayment < ApplicationRecord
  include RegFormHelper
  has_many :registrations, inverse_of: :registration_payment
  has_one :registration_discount, inverse_of: :registration_payment

  validates :total, :stripe_charge_id, presence: true,
            if: Proc.new { |r| r.required_for_step?(:payment) }
  validates :donation_amount, allow_nil: true,
            numericality: { greater_than_or_equal_to: 0 },
            format: { with: /\A\d+(?:\.\d{0,2})?\z/ },
            if: Proc.new { |r| r.required_for_step?(:donation) }
  validate :same_camp_registrations

  serialize :breakdown, Hash

  cattr_accessor :reg_steps do %w[donation payment] end
  attr_accessor :reg_step, :donation_amount, :stripe_token

  def calculate_payment_breakdown # also sets it in the field
    camp = registrations.first.camp
    fee = camp.registration_fee
    sibling_discount = camp.sibling_discount
    shirt_price = camp.shirt_price
    discount = RegistrationDiscount.get(self.discount_code) unless self.discount_code.blank?

    # keep a running total for this payment as we loop through registrations
    running_total = self.additional_donation || 0

    breakdown = {
      registration_fee: fee,
      shirt_price: shirt_price,
      additional_donation: self.additional_donation
    }

    unless discount.nil?
      breakdown[:discount] = {
        code: discount.code,
        percent: discount.discount_percent,
        amount: fee * (discount.discount_percent.to_f/100)
      }
      set_discount(discount)
    end

    campers = []
    registrations.each_with_index do |r, i|
      extra_shirts_total = r.total_additional_shirts * shirt_price
      running_total += fee
      running_total -= breakdown[:discount][:amount] unless discount.blank?
      running_total += extra_shirts_total
      c = {
        name: r.camper.full_name,
        extra_shirts: r.list_additional_shirts,
        extra_shirts_total: extra_shirts_total
      }
      if discount.blank? && i != 0
        c[:sibling_discount] = sibling_discount
        running_total -= sibling_discount
      end
      campers << c
    end

    breakdown[:campers] = campers
    breakdown[:total] = running_total
    self.breakdown = breakdown
    return breakdown
  end

  def calculate_total
    calculate_payment_breakdown if breakdown.blank?
    self.total = breakdown[:total]
    return total
  end

  def process_payment
    calculate_total if total.blank?
    amount = (total*100).to_i
    r = self.registrations.first
    desc = "LYF Camp #{r.camp.year} Registration Payment for #{r.camper.family.primary_parent_email}"
    charge_obj = Stripe::Charge.create(source: stripe_token, amount: amount,
                                       description: desc, currency: 'usd')
    self.stripe_charge_id = charge_obj.id
  end

  private
    def set_discount(discount)
      self.registration_discount = discount
    end

    # custom validation method to ensure all associated registrations are for
    # the same camp year
    def same_camp_registrations
      unless self.registrations.map(&:camp_id).uniq.length == 1
        errors.add(:base, :registrations_for_different_camps,
          message: "registrations must all be for the same camp year")
      end
    end
end
