class RegistrationPayment < ApplicationRecord
  include RegFormHelper
  has_many :registrations, inverse_of: :registration_payment
  has_one :registration_discount, inverse_of: :registration_payment
  accepts_nested_attributes_for :registrations
  has_secure_token :payment_token

  validate :same_camp_registrations
  validates :donation_amount, allow_nil: true,
            numericality: { greater_than_or_equal_to: 0 },
            format: { with: /\A\d+(?:\.\d{0,2})?\z/ },
            if: Proc.new { |r| r.required_for_step?(:donation) }
  validates :total, :payment_type, presence: true,
            if: Proc.new { |r| r.required_for_step?(:payment) }
  validates :stripe_charge_id, :stripe_brand, :stripe_last_four, presence: true,
            if: Proc.new { |r| r.required_for_step?(:payment) && r.payment_type_card? && r.paid }
  validates :stripe_last_four, numericality: { only_integer: true },
            if: Proc.new { |r| r.required_for_step?(:payment) && r.payment_type_card? && r.paid }
  validates :check_number, presence: true,
            if: Proc.new { |r| r.required_for_step?(:payment) && r.payment_type_check? && r.paid }

  before_save :set_total, unless: :paid
  before_save :process_payment, if: Proc.new {|rp| rp.payment_type_card? && !rp.stripe_token.blank? && !rp.paid }

  serialize :breakdown_old, Hash

  enum payment_type: { card: 1, check: 2, cash: 3 }, _prefix: true

  cattr_accessor :reg_steps do %w[donation payment] end
  attr_accessor :reg_step, :donation_amount, :stripe_token

  def calculate_payment_breakdown
    camp = registrations.first.camp
    prereg = registrations.first.preregistration
    late_reg = Time.zone.today >= camp.registration_late_date
    if prereg
      fee = Camp.find_by_year(camp.year-1).registration_fee
    elsif late_reg
      fee = camp.registration_fee + camp.registration_late_fee
    else
      fee = camp.registration_fee
    end
    # fee = camp.registration_fee + (late_reg ? camp.registration_late_fee : 0)
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
      if discount.blank? && i != 0 && !(late_reg || prereg)
        c[:sibling_discount] = sibling_discount
        running_total -= sibling_discount
      end
      campers << c
    end

    breakdown[:campers] = campers
    breakdown[:total] = running_total
    return breakdown
  end

  def set_breakdown
    self.breakdown = self.calculate_payment_breakdown
  end

  def set_total
    self.set_breakdown
    self.total = self.breakdown["total"]
  end

  def copy_breakdown_from_old
    self.breakdown = self.breakdown_old
    self.save
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
      calculate_total if total.blank?
      r = self.registrations.first
      desc = "LYF Camp #{r.camp.year} Registration Payment\n"
      desc += "Parent: #{r.camper.family.primary_parent} (#{r.camper.family.primary_parent_email})"
      desc += "\nCampers: "
      desc += self.registrations.map{ |reg| reg.camper.full_name }.join(", ").chomp(", ")
      charge_result = CreditCardService.new({
        token: stripe_token,
        amount: total,
        desc: desc
      }).charge
      if charge_result.charge_succeeded?
        charge_obj = charge_result.charge_obj
        self.stripe_charge_id = charge_obj.id
        self.stripe_brand = charge_obj.source.brand
        self.stripe_last_four = charge_obj.source.last4
        self.paid = true
        return true
      else
        errors.add(:base, :payment_failed,
                   message: charge_result.error_messages)
        throw(:abort)
      end
    end
end
