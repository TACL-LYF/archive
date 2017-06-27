class LastDayPurchase < ApplicationRecord
  validates :first_name, :last_name, :email, :address, :city, :state,
            :zip, presence: true
  validates :email, length: { maximum: 255 }, format: VALID_EMAIL_REGEX
  validates :phone, phone: { allow_blank: true }
  validates :state, length: { is: 2 }
  validates :zip, length: { minimum: 5 }
  validates :amount, presence: true
  validates :amount, numericality: { greater_than: 0 },
            format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, unless: 'amount.nil?'
  validates :stripe_last_four, length: { is: 4 },
            numericality: { only_integer: true }, allow_blank: true

  before_validation :normalize_names
  before_save { self.email = email.downcase }
  before_save :normalize_phone

  before_create :process_payment

  attr_accessor :stripe_token

  private
    def normalize_names
      fields = %w[first_name last_name address city]
      fields.each do |field|
        unless self.send("#{field}").nil?
          self.send("#{field}=", self.send("#{field}").strip.gsub(/\b\w/, &:upcase))
        end
      end
      self.state = state.strip.upcase unless self.state.nil?
    end

    def normalize_phone
      unless self.phone.nil?
        p = Phonelib.parse(self.phone)
        self.phone = p.countries.include?("US") ? p.full_national : p.full_international
      end
    end

    def process_payment
      charge_result = CreditCardService.new({
        token: stripe_token,
        amount: amount,
        desc: "Donation Payment from #{first_name} #{last_name} (#{email})"
      }).charge
      if charge_result.charge_succeeded?
        charge_obj = charge_result.charge_obj
        self.stripe_charge_id = charge_obj.id
        self.stripe_brand = charge_obj.source.brand
        self.stripe_last_four = charge_obj.source.last4
        return true
      else
        errors.add(:base, :payment_failed,
                   message: charge_result.error_messages)
        throw(:abort)
      end
    end
end
