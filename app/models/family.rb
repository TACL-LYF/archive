class Family < ApplicationRecord
  include RegFormHelper
  has_many :campers, inverse_of: :family, dependent: :destroy
  has_many :referrals, inverse_of: :family, dependent: :destroy
  has_many :referral_methods, through: :referrals

  accepts_nested_attributes_for :campers
  accepts_nested_attributes_for :referrals, allow_destroy: true

  cattr_accessor :reg_steps do %w[parent referral] end
  attr_accessor :reg_step

  before_validation :normalize_names
  before_save { self.primary_parent_email = primary_parent_email.downcase }
  before_save { self.secondary_parent_email = secondary_parent_email.downcase if !secondary_parent_email.nil?}
  before_save :normalize_phone_numbers

  with_options :if => Proc.new { |p| p.required_for_step?(:parent) } do
    validates :primary_parent_first_name, :primary_parent_last_name,
              :primary_parent_email, :primary_parent_phone_number, :street,
              :city, :state, :zip, presence: true
    validates :primary_parent_first_name, :primary_parent_last_name,
              :secondary_parent_first_name, :secondary_parent_last_name,
              length: { maximum: 50 }
    validates :primary_parent_email, length: { maximum: 255 },
              format: VALID_EMAIL_REGEX, unless: "primary_parent_email.blank?"
    validates :secondary_parent_email, length: { maximum: 255 },
              format: VALID_EMAIL_REGEX, allow_blank: true
    validates :primary_parent_phone_number, phone: true,
              unless: "primary_parent_phone_number.blank?"
    validates :secondary_parent_phone_number, phone: { allow_blank: true }
    validates :state, length: { is: 2 }, unless: "state.blank?"
    validates :zip, length: { minimum: 5 }, unless: "zip.blank?"
  end

  def primary_parent
    "#{primary_parent_first_name} #{primary_parent_last_name}"
  end

  def secondary_parent
    "#{secondary_parent_first_name} #{secondary_parent_last_name}"
  end

  def list_referral_methods
    self.referrals.reduce("") { |memo, r|
      memo + r.referral_method.name + (r.details.blank? ? "" : " (#{r.details})") + ", "
    }.chomp(", ")
  end

  private
    def normalize_names
      fields = %w[primary_parent_first_name primary_parent_last_name
        secondary_parent_first_name secondary_parent_last_name suite street city
      ]
      fields.each do |field|
        unless self.send("#{field}").nil?
          self.send("#{field}=", self.send("#{field}").strip.gsub(/\b\w/, &:upcase))
        end
      end
      self.state = state.strip.upcase unless self.state.nil?
    end

    def normalize_phone_numbers
      fields = %w[primary_parent_phone_number secondary_parent_phone_number]
      fields.each do |field|
        unless self.send("#{field}").nil?
          phone = Phonelib.parse(self.send("#{field}"))
          phone = phone.countries.include?("US") ? phone.full_national : phone.full_international
          self.send("#{field}=", phone)
        end
      end
    end
end
