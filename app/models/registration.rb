class Registration < ApplicationRecord
  include RegFormHelper
  belongs_to :camp, inverse_of: :registrations
  belongs_to :camper, inverse_of: :registrations
  belongs_to :registration_payment, inverse_of: :registrations, optional: true

  cattr_accessor :reg_steps do %w[details waiver review] end
  attr_accessor :reg_step, :returning

  validates :camp, :camper, :city, :state, presence: true
  validates :grade, :inclusion => 3..12,
            :if => Proc.new { |r| r.required_for_step?(:details) }
  validates :shirt_size, presence: true,
            :if => Proc.new { |r| r.required_for_step?(:details) }
  with_options :if => Proc.new { |r| r.required_for_step?(:details) } do
    validates_inclusion_of :bus, in: [true, false],
                           message: "information required"
  end
  validates :waiver_signature, :waiver_date, presence: true,
            :if => Proc.new { |r| r.required_for_step?(:waiver) }
  enum shirt_size: Hash[SHIRT_SIZES.zip (0..SHIRT_SIZES.size)]
  enum group: ('A'..'Z').to_a.map!(&:to_sym)
  store :additional_shirts, accessors: SHIRT_SIZES

  def total_additional_shirts
    num_shirts = additional_shirts.values.map(&:to_i).reduce(:+)
    return num_shirts || 0
  end

  def list_additional_shirts
    additional_shirts.reject{ |size, n| n == "" }.
    reduce(""){|str, (size,n)| "#{str}#{size.titlecase} (#{n}), "}.
    chomp(", ")
  end

end
