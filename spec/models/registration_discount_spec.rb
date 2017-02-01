require 'rails_helper'

RSpec.describe RegistrationDiscount, type: :model do
  let(:camp) { build(:camp) }
  it "has a valid factory" do
    expect(build(:registration_discount)).to be_valid
  end
  it "is invalid without a camp" do
    expect(build(:registration_discount, camp: nil)).to_not be_valid
  end
  it "is invalid without a code" do
    expect(build(:registration_discount, code: nil)).to_not be_valid
  end
  it "is invalid without a integer discount percent" do
    [nil, 0, 1.5, 101].each do |val|
      expect(build(:registration_discount, camp: camp, discount_percent: val)).to_not be_valid
    end
  end
end
