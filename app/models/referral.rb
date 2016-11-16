class Referral < ApplicationRecord
  belongs_to :family, inverse_of: :referrals, dependent: :destroy
  belongs_to :referral_method, inverse_of: :referrals, dependent: :destroy

  validates :family, :referral_method, presence: true

  attr_accessor :enable
end
