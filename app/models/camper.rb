class Camper < ApplicationRecord
  include RegFormHelper
  belongs_to :family, inverse_of: :campers
  delegate :primary_parent_email, :primary_parent_phone_number,
           :secondary_parent_email, :secondary_parent_phone_number,
           :street, :suite, :city, :state, :zip, to: :family, allow_nil: true
  has_many :registrations, inverse_of: :camper, dependent: :destroy
  has_many :registration_payments, through: :registrations
  accepts_nested_attributes_for :registrations

  default_scope -> { order(first_name: :asc) }

  cattr_accessor :reg_steps do %w[camper] end
  attr_accessor :reg_step, :birth_year, :birth_month, :birth_day

  before_save { self.email = email.downcase unless email.nil? }
  before_validation :normalize_names

  with_options :if => Proc.new { |c| c.required_for_step?(:camper) } do
    validates :first_name, :last_name, presence: true, length: { maximum: 50 }
    validates :family, :gender, presence: true
    validates :birth_year, :birth_month, :birth_day, presence: true,
              unless: -> { !birthdate.nil? }
    validates :email, length: { maximum: 255 }, format: VALID_EMAIL_REGEX,
              allow_blank: true
    validates :returning, inclusion: { in: [true, false],
                                 message: "information required" }
    validate :birthdate_is_valid,
             unless: -> { birth_year.nil? || birth_month.nil? || birth_day.nil? }
  end
  validates :medical_conditions_and_medication, :diet_and_food_allergies,
            presence: { message: "required. If none, please write \"N/A\"" },
            if: Proc.new { |c| c.required_for_step?(:camper) }

  enum gender: { male: 0, female: 1 }
  enum status: { active: 0, graduated: 1 }

  def full_name
    "#{first_name} #{last_name}"
  end

  def gender_abbr
    self[:gender][0].upcase
  end

  private
    def normalize_names
      fields = %w[first_name last_name]
      fields.each do |field|
        unless self.send("#{field}").nil?
          self.send("#{field}=", self.send("#{field}").strip.gsub(/\b\w/, &:upcase))
        end
      end
    end

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
