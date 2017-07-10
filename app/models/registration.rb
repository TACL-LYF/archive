class Registration < ApplicationRecord
  include RegFormHelper
  belongs_to :camp, inverse_of: :registrations
  belongs_to :camper, inverse_of: :registrations
  belongs_to :registration_payment, inverse_of: :registrations, optional: true
  delegate :family, :birthdate, :gender, :medical_conditions_and_medication,
           :diet_and_food_allergies, :returning, :primary_parent_email,
           :primary_parent_phone_number, :secondary_parent_email,
           :secondary_parent_phone_number, :suite, :street, :zip,
           to: :camper, allow_nil: true
  delegate :email, to: :camper, prefix: true, allow_nil: true

  before_validation :copy_city_state_from_family
  before_create :set_waitlist,
    if: Proc.new { |r| r.camp.is_registration_closed? && !r.preregistration }

  cattr_accessor :reg_steps do %w[details camper_involvement waiver review] end
  attr_accessor :reg_step, :waiver_year, :waiver_month, :waiver_day

  validates :camp, :camper, :city, :state, presence: true
  validates :grade, inclusion: 3..12,
            if: Proc.new { |r| r.required_for_step?(:details) }
  validates :shirt_size, presence: true,
            if: Proc.new { |r| r.required_for_step?(:details) && !preregistration }
  with_options if: Proc.new { |r| r.required_for_step?(:details) } do
    validates :bus, inclusion: { in: [true, false],
                                 message: "information required" }
  end
  with_options if: Proc.new { |r| r.required_for_step?(:waiver) } do
    validates :waiver_signature, presence: true, unless: :preregistration
    validates :waiver_year, :waiver_month, :waiver_day, presence: true,
              unless: "!waiver_date.nil? || preregistration"
    validate :waiver_signature_matches_name, on: :create, unless: :preregistration
    validate :waiver_date_matches_date, on: :create, unless: :preregistration
  end

  enum status: { active: 0, cancelled: 1, waitlist: 2 }
  enum shirt_size: Hash[SHIRT_SIZES.zip (0..SHIRT_SIZES.size)]
  enum group: ('A'..'Z').to_a.map!(&:to_sym)
  store :additional_shirts, accessors: SHIRT_SIZES
  store :camper_involvement, accessors: CAMPER_ROLES

  def pretty_shirt_size
    prettify_shirt_size(self.shirt_size)
  end

  def total_additional_shirts
    num_shirts = additional_shirts.values.map(&:to_i).reduce(:+)
    return num_shirts || 0
  end

  def list_additional_shirts
    list = additional_shirts.reject{ |size, n| n == "" }.
           reduce(""){|str, (size,n)| "#{str}#{prettify_shirt_size(size)} (#{n}), "}.
           chomp(", ")
    list.blank? ? "None" : list
  end

  def list_camper_involvement
    list = camper_involvement.reject{ |role, v| v.blank? }.keys.
           map{ |role| role.to_s.titlecase }.join(", ").chomp(", ")
    list.blank? ? "None" : list
  end

  private
    def prettify_shirt_size(size)
      size.titlecase.gsub(/^(.+?)\s/){|x| x.upcase}
    end

    def copy_city_state_from_family
      return if camper.nil?
      self.city = camper.family.city
      self.state = camper.family.state
    end

    def set_waitlist
      self.status = :waitlist
    end

    def waiver_signature_matches_name
      return if waiver_signature.nil? || camper.nil?
      parent_name = camper.family.primary_parent.gsub(/\s+/, "").downcase
      unless parent_name == waiver_signature.gsub(/\s+/, "").downcase
        errors.add(:waiver_signature, "doesn't seem to match the primary parent name")
      end
    end

    def waiver_date_matches_date
      begin
        self.waiver_date ||= Date.parse(waiver_day+" "+waiver_month+" "+waiver_year)
        unless waiver_date <= Time.zone.today+1 && waiver_date >= Time.zone.today-1
          errors.add(:waiver_date, "doesn't seem to be the current date")
        end
      rescue
        errors.add(:waiver_date, "is not a valid date")
      end
    end
end
