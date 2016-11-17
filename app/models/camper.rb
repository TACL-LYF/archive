class Camper < ApplicationRecord
  include RegFormHelper
  belongs_to :family, inverse_of: :campers
  has_many :registrations, inverse_of: :camper
  accepts_nested_attributes_for :registrations
  before_save { self.email = email.downcase if !email.nil? }
  with_options :if => Proc.new { |c| c.required_for_step?(:camper) } do
    validates :first_name, :last_name, presence: true, length: { maximum: 50 }
    validates :gender, :birthdate, presence: true
    validates :birthdate, uniqueness: { scope: [:first_name, :last_name] }
    validates :email, length: { maximum: 255 }, format: VALID_EMAIL_REGEX,
              allow_blank: true
  end
  validates :medical_conditions_and_medication, :diet_and_food_allergies,
            presence: { message: "required. If none, please write \"N/A\"" },
            :if => Proc.new { |c| c.required_for_step?(:camper) }
  enum gender: { male: 0, female: 1 }
  enum status: { active: 0, graduated: 1 }

  cattr_accessor :reg_steps do %w[camper] end
  attr_accessor :reg_step

  def full_name
    "#{first_name} #{last_name}"
  end

  def get_status
    status.titlecase
  end

  def get_gender
    gender[0].upcase
  end
end
