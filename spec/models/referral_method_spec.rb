require 'rails_helper'

RSpec.describe ReferralMethod, type: :model do
  it "has a valid factory" do
    expect(build(:referral_method)).to be_valid
  end
  it "is invalid without a name" do
    expect(build(:referral_method, name: nil)).to_not be_valid
  end
  it "is invalid without a details field label if allow_details is true" do
    expect(build(:referral_method, allow_details: true, details_field_label: nil)).to_not be_valid
  end
end
