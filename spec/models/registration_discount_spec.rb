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

  describe ".normalize_code" do
    it "removes whitespace characters and upcases the entire code" do
      expect(RegistrationDiscount.normalize_code("test code")).to eq("TESTCODE")
    end
  end

  describe ".get" do
    let(:stripe_helper) { StripeMock.create_test_helper }
    before { StripeMock.start }
    after { StripeMock.stop }

    it "returns the unredeemed discount with the supplied code, if it exists" do
      discount = create(:registration_discount)
      expect(RegistrationDiscount.get(discount.code)).to eq(discount)
    end
    it "returns nil if code has already been redeemed or does not exist" do
      create(:registration_discount, code: "redeemed")
      create(:registration_payment, discount_code: "redeemed", stripe_token: stripe_helper.generate_card_token)
      expect(RegistrationDiscount.get("redeemed")).to be_nil
      expect(RegistrationDiscount.get("nonexistent")).to be_nil
    end
  end
end
