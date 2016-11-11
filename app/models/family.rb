class Family < ApplicationRecord
  include RegFormHelper

  before_save { self.email = email.downcase }
  with_options :if => Proc.new { |p| p.required_for_step?(:parent) } do
    validates :primary_parent_first_name, :primary_parent_last_name,
              :primary_parent_phone_number, :street, :city, presence: true
    validates :primary_parent_first_name, :primary_parent_last_name,
              :secondary_parent_first_name, :secondary_parent_last_name,
              length: { maximum: 50 }
    validates :primary_parent_email, :secondary_parent_email,
              length: { maximum: 255 }, format: VALID_EMAIL_REGEX
    validates :secondary_parent_email, allow_blank: true
    validates :state, length: { is: 2 }
    validates :zip, length: { minimum: 5 }
  end

  cattr_accessor :reg_steps do %w[parent referral] end
  attr_accessor :reg_step

  def parent_full_name
    "#{primary_parent_first_name} #{primary_parent_last_name}"
  end
end
