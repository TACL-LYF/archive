require 'rails_helper'

RSpec.describe Donation, type: :model do
  it "has a valid factory" do
    expect(build(:donation)).to be_valid
  end
  it "is invalid without a first name" do
    expect(build(:donation, first_name: nil)).to_not be_valid
  end
  it "is invalid without a last name" do
    expect(build(:donation, last_name: nil)).to_not be_valid
  end
  it "is invalid without a valid email address" do
    expect(build(:donation, email: nil)).to_not be_valid
    invalid_addresses = %w[user@example,com user_at_foo.org
                           user.name@example.foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |address|
      expect(build(:donation, email: address)).to_not be_valid
    end
  end
  it "is invalid without all required address fields" do
    expect(build(:donation, address: nil)).to_not be_valid
    expect(build(:donation, city: nil)).to_not be_valid
    expect(build(:donation, state: nil)).to_not be_valid
    expect(build(:donation, zip: nil)).to_not be_valid
  end
  it "is invalid without a numerical amount" do
    expect(build(:donation, amount: nil)).to_not be_valid
    expect(build(:donation, amount: "string")).to_not be_valid
  end
  context "when a donation is created" do
    let(:stripe_helper) { StripeMock.create_test_helper }
    before { StripeMock.start }
    after { StripeMock.stop }
    it "charges the card and sets the stripe fields" do
      donation = create(:donation, stripe_token: stripe_helper.generate_card_token)
      expect(donation.stripe_charge_id).to_not be_nil
      expect(donation.stripe_brand).to_not be_nil
      expect(donation.stripe_last_four).to_not be_nil
    end
  end
end
