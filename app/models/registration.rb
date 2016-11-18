class Registration < ApplicationRecord
  include RegFormHelper
  belongs_to :camp, inverse_of: :registrations
  belongs_to :camper, inverse_of: :registrations

  cattr_accessor :reg_steps do %w[details waiver review] end
  attr_accessor :reg_step, :shirt_size

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

  enum group: ('A'..'Z').to_a.map!(&:to_sym)
  store :additional_shirts, accessors: [:x_small, :small, :medium, :large, :x_large, :xx_large]

end
