require 'rails_helper'

RSpec.describe LastDayPurchase, type: :model do
  it "has a valid factory" do
    expect(build(:last_day_purchase)).to be_valid
  end
  it "is invalid without a first name" do
    expect(build(:last_day_purchase, first_name: nil)).to_not be_valid
  end
  it "is invalid without a last name" do
    expect(build(:last_day_purchase, last_name: nil)).to_not be_valid
  end
  it "is invalid without a valid email address" do
    expect(build(:last_day_purchase, email: nil)).to_not be_valid
    invalid_addresses = %w[user@example,com user_at_foo.org
                           user.name@example.foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |address|
      expect(build(:last_day_purchase, email: address)).to_not be_valid
    end
  end
  it "is invalid without all required address fields" do
    expect(build(:last_day_purchase, address: nil)).to_not be_valid
    expect(build(:last_day_purchase, city: nil)).to_not be_valid
    expect(build(:last_day_purchase, state: nil)).to_not be_valid
    expect(build(:last_day_purchase, zip: nil)).to_not be_valid
  end
  it "is invalid without a numerical amount" do
    expect(build(:last_day_purchase, amount: nil)).to_not be_valid
    expect(build(:last_day_purchase, amount: "string")).to_not be_valid
  end
  context "when a last_day_purchase is created" do
    let(:stripe_helper) { StripeMock.create_test_helper }
    before { StripeMock.start }
    after { StripeMock.stop }
    it "charges the card and sets the stripe fields" do
      last_day_purchase = create(:last_day_purchase, stripe_token: stripe_helper.generate_card_token)
      expect(last_day_purchase.stripe_charge_id).to_not be_nil
      expect(last_day_purchase.stripe_brand).to_not be_nil
      expect(last_day_purchase.stripe_last_four).to_not be_nil
    end
  end
end
