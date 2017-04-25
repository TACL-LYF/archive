class Camp < ApplicationRecord
  has_many :registrations, inverse_of: :camp
  has_many :registration_discounts, inverse_of: :camp

  validates :year, presence: true, uniqueness: true
  default_scope -> { order(year: :desc) }

  def get_summary
    shirt_totals = Hash.new(0)
    gender_breakdown = Hash.new(0)
    grade_breakdown = Hash.new(0)
    bus_total = 0

    registrations.all.each do |r|
      shirt_totals[r.shirt_size] += 1
      r.additional_shirts.each do |size, count|
        shirt_totals[size] += count.to_i
      end
      gender_breakdown[r.gender] += 1
      grade_breakdown[r.grade] += 1
      bus_total += 1 if r.bus
    end

    return {
      total_registrations: registrations.count,
      bus_total: bus_total,
      gender_breakdown: gender_breakdown,
      grade_breakdown: grade_breakdown,
      shirt_totals: shirt_totals
    }
  end
end
