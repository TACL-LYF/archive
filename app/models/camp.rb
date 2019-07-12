class Camp < ApplicationRecord
  has_many :registrations, inverse_of: :camp
  has_many :registration_discounts, inverse_of: :camp

  default_scope -> { order(year: :desc) }

  validates :year, presence: true, uniqueness: true

  def get_summary
    shirt_totals = SHIRT_SIZES.map { |size| [size.to_s, 0] }.to_h
    gender_breakdown = Hash.new(0)
    grade_breakdown = (3..12).to_a.map { |grade| [grade, 0] }.to_h
    bus_total = 0

    active_regs = registrations.active.includes(:camper)

    active_regs.each do |r|
      shirt_totals[r.shirt_size] += 1
      a_s = r.additional_shirts
      unless [nil, "", {}, "{}"].include?(a_s)
        a_s = eval(a_s) unless a_s.is_a?(Hash)
        a_s.each do |size, count|
          shirt_totals[size] += count.to_i
        end
      end
      gender_breakdown[r.gender] += 1
      grade_breakdown[r.grade] += 1
      bus_total += 1 if r.bus
    end

    return {
      active: registrations.active.size,
      cancelled: registrations.cancelled.size,
      waitlist: registrations.waitlist.size,
      bus_total: bus_total,
      gender_breakdown: gender_breakdown,
      grade_breakdown: grade_breakdown,
      shirt_totals: shirt_totals
    }
  end

  def to_s
    "#{year}: #{name}"
  end

  def is_late_registration?
    Time.zone.today > registration_late_date
  end

  def is_registration_closed?
    Time.zone.today > registration_close_date
  end

  def is_waitlist_period?
    if waitlist_starts_after.nil?
      is_registration_closed?
    else
      is_registration_closed? || registrations.active.count >= waitlist_starts_after
    end
  end
end
