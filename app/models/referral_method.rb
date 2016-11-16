class ReferralMethod < ApplicationRecord
  has_many :referrals, inverse_of: :referral_method
  has_many :families, through: :referrals
  validates :name, presence: true
  validates_inclusion_of :allow_details, in: [true, false]
end
