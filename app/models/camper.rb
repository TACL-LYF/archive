class Camper < ApplicationRecord
  include RegFormHelper
  belongs_to :family, inverse_of: :campers
  has_many :registrations, inverse_of: :camper
  accepts_nested_attributes_for :registrations

  cattr_accessor :reg_steps do %w[camper] end
  attr_accessor :reg_step, :returning

  before_save { self.email = email.downcase unless email.nil? }
  before_validation :normalize_name

  with_options :if => Proc.new { |c| c.required_for_step?(:camper) } do
    validates :first_name, :last_name, presence: true, length: { maximum: 50 }
    validates :gender, :birthdate, presence: true
    validates :email, length: { maximum: 255 }, format: VALID_EMAIL_REGEX,
              allow_blank: true
  end
  validates :medical_conditions_and_medication, :diet_and_food_allergies,
            presence: { message: "required. If none, please write \"N/A\"" },
            if: Proc.new { |c| c.required_for_step?(:camper) }
  validates :returning, presence: true,
            if: Proc.new { |c| c.reg_step == "camper" }

  enum gender: { male: 0, female: 1 }
  enum status: { active: 0, graduated: 1 }

  def full_name
    "#{first_name} #{last_name}"
  end

  def get_status
    status.titlecase
  end

  def get_gender
    gender[0].upcase
  end

  protected
    def normalize_name
      self.first_name.strip! unless first_name.nil?
      self.last_name.strip! unless last_name.nil?
    end
end
