class Camp < ApplicationRecord
  has_many :registrations, inverse_of: :camp
  has_many :registration_discounts, inverse_of: :camp
  validates :year, presence: true, uniqueness: true
  default_scope -> { order(year: :desc) }
end
