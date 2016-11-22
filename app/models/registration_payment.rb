class RegistrationPayment < ApplicationRecord
  include RegFormHelper
  has_many :registrations, inverse_of: :registration_payment
  has_one :registration_discount, inverse_of: :registration_payment

  validates :total, :stripe_token, presence: true,
            :if => Proc.new { |r| r.required_for_step?(:payment) }
  validate :same_camp_registrations

  cattr_accessor :reg_steps do %w[donation payment] end
  attr_accessor :reg_step, :donation_amount

  def get_payment_breakdown # also sets the total amount on the record
    camp = registrations.first.camp
    fee = camp.registration_fee
    sibling_discount = camp.sibling_discount
    shirt_price = camp.shirt_price
    discount = self.registration_discount

    # keep a running total for this payment as we loop through registrations
    running_total = self.additional_donation || 0

    breakdown = {
      registration_fee: fee,
      shirt_price: shirt_price,
      additional_donation: self.additional_donation
    }

    unless discount.nil?
      d = {
        code: discount.code,
        percent: discount.discount_percent,
        amount: fee * (discount.discount_percent/100)
      }
      breakdown[:discount] = d
    end

    campers = []
    registrations.each_with_index do |r, i|
      extra_shirts_total = r.total_additional_shirts * shirt_price
      running_total += fee
      running_total -= breakdown[:discount][:amount] unless discount.nil?
      running_total += extra_shirts_total
      c = {
        name: r.camper.full_name,
        extra_shirts: r.list_additional_shirts,
        extra_shirts_total: extra_shirts_total
      }
      if discount.nil? && i != 0
        c[:sibling_discount] = sibling_discount
        running_total -= sibling_discount
      end
      campers << c
    end

    breakdown[:campers] = campers
    self.total = breakdown[:total] = running_total
    return breakdown
  end

  private
    # custom validation method to ensure all associated registrations are for
    # the same camp year
    def same_camp_registrations
      unless self.registrations.map(&:camp_id).uniq.length == 1
        errors.add(:base, :registrations_for_different_camps,
          message: "registrations must all be for the same camp year")
      end
    end
end
