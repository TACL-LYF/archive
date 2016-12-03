class Family < ApplicationRecord
  include RegFormHelper
  has_many :campers, inverse_of: :family
  has_many :referrals, inverse_of: :family
  has_many :referral_methods, through: :referrals
  accepts_nested_attributes_for :referrals, allow_destroy: true

  cattr_accessor :reg_steps do %w[parent referral] end
  attr_accessor :reg_step

  before_validation :normalize_names
  before_save { self.primary_parent_email = primary_parent_email.downcase }
  before_save { self.secondary_parent_email = secondary_parent_email.downcase if !secondary_parent_email.nil?}

  with_options :if => Proc.new { |p| p.required_for_step?(:parent) } do
    validates :primary_parent_first_name, :primary_parent_last_name,
              :primary_parent_phone_number, :street, :city, presence: true
    validates :primary_parent_first_name, :primary_parent_last_name,
              :secondary_parent_first_name, :secondary_parent_last_name,
              length: { maximum: 50 }
    validates :primary_parent_email, length: { maximum: 255 },
              format: VALID_EMAIL_REGEX
    validates :secondary_parent_email, length: { maximum: 255 },
              format: VALID_EMAIL_REGEX, allow_blank: true
    validates :state, length: { is: 2 }
    validates :zip, length: { minimum: 5 }
  end

  def primary_parent
    "#{primary_parent_first_name} #{primary_parent_last_name}"
  end

  def secondary_parent
    "#{secondary_parent_first_name} #{secondary_parent_last_name}"
  end

  protected
    def normalize_names
      self.primary_parent_first_name.strip!
      self.primary_parent_last_name.strip!
      self.secondary_parent_first_name.strip! unless secondary_parent_first_name.nil?
      self.secondary_parent_last_name.strip! unless secondary_parent_last_name.nil?
    end
end
