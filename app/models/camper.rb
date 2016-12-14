class Camper < ApplicationRecord
  include RegFormHelper
  belongs_to :family, inverse_of: :campers
  has_many :registrations, inverse_of: :camper
  accepts_nested_attributes_for :registrations

  cattr_accessor :reg_steps do %w[camper] end
  attr_accessor :reg_step, :birth_year, :birth_month, :birth_day

  before_save { self.email = email.downcase unless email.nil? }
  before_validation :normalize_name

  with_options :if => Proc.new { |c| c.required_for_step?(:camper) } do
    validates :first_name, :last_name, presence: true, length: { maximum: 50 }
    validates :gender, :birth_year, :birth_month, :birth_day, presence: true
    validates :email, length: { maximum: 255 }, format: VALID_EMAIL_REGEX,
              allow_blank: true
    validates :returning, inclusion: { in: [true, false],
                                 message: "information required" }
    validate :birthdate_is_valid,
             unless: "birth_year.nil? || birth_month.nil? || birth_day.nil?"
  end
  validates :medical_conditions_and_medication, :diet_and_food_allergies,
            presence: { message: "required. If none, please write \"N/A\"" },
            if: Proc.new { |c| c.required_for_step?(:camper) }

  enum gender: { male: 0, female: 1 }
  enum status: { active: 0, graduated: 1 }

  def full_name
    "#{first_name} #{last_name}"
  end

  def status
    self[:status].titlecase
  end

  def gender_abbr
    self[:gender][0].upcase
  end

  protected
    def normalize_name
      self.first_name.strip! unless first_name.nil?
      self.last_name.strip! unless last_name.nil?
    end

  private
    def birthdate_is_valid
      begin
        self.birthdate = Date.parse(birth_day + " " + birth_month + " " + birth_year)
        unless birth_year.to_i >= 20.years.ago.year && birth_year.to_i <= 5.years.ago.year
          errors.add(:birthdate, "is not within the accepted range")
        end
      rescue
        errors.add(:birthdate, "is not a valid date")
      end
    end
end
