class RegistrationPayment < ApplicationRecord
  include RegFormHelper
  has_many :registrations, inverse_of: :registration_payment
  has_one :registration_discount, inverse_of: :registration_payment

  before_create :process_payment

  validate :same_camp_registrations
  validates :donation_amount, allow_nil: true,
            numericality: { greater_than_or_equal_to: 0 },
            format: { with: /\A\d+(?:\.\d{0,2})?\z/ },
            if: Proc.new { |r| r.required_for_step?(:donation) }
  with_options if: Proc.new { |r| r.required_for_step?(:payment) } do
    validates :total, :stripe_charge_id, :stripe_brand, presence: true
    validates :stripe_last_four, presence: true, length: { is: 4 },
              numericality: { only_integer: true }
  end

  serialize :breakdown, Hash

  cattr_accessor :reg_steps do %w[donation payment] end
  attr_accessor :reg_step, :donation_amount, :stripe_token

  def calculate_payment_breakdown # also sets it in the field
    camp = registrations.first.camp
    late_reg = Date.today >= camp.registration_late_date
    fee = camp.registration_fee + (late_reg ? camp.registration_late_fee : 0)
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
        shirt_size: r.shirt_size.titlecase.gsub(/^(.+?)\s/){|x| x.upcase},
        extra_shirts: r.list_additional_shirts,
        extra_shirts_total: extra_shirts_total
      }
      if discount.blank? && i != 0 && !late_reg
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
    calculate_payment_breakdown
    self.total = breakdown[:total]
    return total
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

    def reject_if_amex
      token = Stripe::Token.retrieve(stripe_token)
      if token.card.brand == "American Express"
        raise Exceptions::AmexError
      end
    end

    def process_payment
      reject_if_amex
      calculate_total if total.blank?
      amount = (total*100).to_i
      r = self.registrations.first
      desc = "LYF Camp #{r.camp.year} Registration Payment for #{r.camper.family.primary_parent_email}"
      charge_obj = Stripe::Charge.create(source: stripe_token, amount: amount,
                                         description: desc, currency: 'usd')
      self.stripe_charge_id = charge_obj.id
      self.stripe_brand = charge_obj.source.brand
      self.stripe_last_four = charge_obj.source.last4
    end
end
