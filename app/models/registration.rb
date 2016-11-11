class Registration < ApplicationRecord
  include RegFormHelper
  belongs_to :camp, inverse_of: :registrations
  belongs_to :camper, inverse_of: :registrations
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
  enum shirt_size: { x_small: 0, small: 1, medium: 2, large: 3, x_large: 4, xx_large: 5}
  enum group: ('A'..'Z').to_a.map!(&:to_sym)

  cattr_accessor :reg_steps do %w[details waiver review] end
  attr_accessor :reg_step
end
