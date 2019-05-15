class Registration < ApplicationRecord
  include RegFormHelper
  belongs_to :camp, inverse_of: :registrations
  belongs_to :camper, inverse_of: :registrations
  belongs_to :registration_payment, inverse_of: :registrations, optional: true
  delegate :family, :birthdate, :gender, :medical_conditions_and_medication,
           :diet_and_food_allergies, :returning, :primary_parent_email,
           :primary_parent_phone_number, :secondary_parent_email,
           :secondary_parent_phone_number, :suite, :street, :state, :zip,
           :first_name, :last_name, :full_name, to: :camper, allow_nil: true
  delegate :email, to: :camper, prefix: true, allow_nil: true

  before_validation :copy_city_state_from_family
  before_create :set_waitlist,
    if: Proc.new { |r| r.camp.is_waitlist_period? && !r.preregistration }

  cattr_accessor :reg_steps do %w[details camper_involvement waiver review] end
  attr_accessor :reg_step, :waiver_year, :waiver_month, :waiver_day,
                :grade_entering, :admin_skip_validations

  validates :camp, :camper, :city, :state, presence: true
  with_options if: Proc.new { |r| r.required_for_step?(:details) } do
    validates :grade, inclusion: 3..12
    validates :shirt_size, presence: true
    validates :bus, inclusion: { in: [true, false],
                                 message: "acknowledgement required" }
  end
  with_options unless: :admin_skip_validations do
    validates :grade_entering, presence: true,
              if: Proc.new { |r| r.required_for_step?(:details) }
    with_options if: Proc.new { |r| r.required_for_step?(:waiver) } do
      validates :waiver_signature, presence: true
      validates :waiver_year, :waiver_month, :waiver_day, presence: true
      validate :waiver_signature_matches_name, on: :create
      validate :waiver_date_matches_date, on: :create
    end
  end

  enum status: { active: 0, cancelled: 1, waitlist: 2 }
  enum shirt_size: Hash[SHIRT_SIZES.zip (0..SHIRT_SIZES.size)]
  enum group: ('A'..'Z').to_a.map!(&:to_sym)
  #store :additional_shirts, accessors: SHIRT_SIZES
  #store :camper_involvement, accessors: CAMPER_ROLES
  store_accessor :additional_shirts, SHIRT_SIZES
  store_accessor :camper_involvement, CAMPER_ROLES

  def pretty_shirt_size
    prettify_shirt_size(self.shirt_size)
  end

  def total_additional_shirts
    num_shirts = additional_shirts.values.map(&:to_i).reduce(:+)
    return num_shirts || 0
  end

  def list_additional_shirts
    as = [nil, "{}", ""].include?(additional_shirts) ? Hash.new : additional_shirts
    as.reject{ |size, n| n == "" }.
      reduce(""){|str, (size,n)| "#{str}#{prettify_shirt_size(size)} (#{n}), "}.
      chomp(", ")
  end

  def list_camper_involvement
    ci = [nil, "{}", ""].include?(camper_involvement) ? Hash.new : camper_involvement
    ci.reject{ |role, v| v.blank? }.keys.
      map{ |role| role.to_s.titlecase }.join(", ").chomp(", ")
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
