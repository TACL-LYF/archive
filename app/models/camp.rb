class Camp < ApplicationRecord
  validates :year, presence: true, uniqueness: true
  default_scope -> { order(year: :desc) }
end
