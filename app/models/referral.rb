class Referral < ApplicationRecord
  belongs_to :family, inverse_of: :referrals
  belongs_to :referral_method, inverse_of: :referrals

  validates :family, :referral_method, presence: true
end
