require 'rails_helper'

RSpec.describe RegistrationPayment, type: :model do
  it "has a valid factory" do
    expect(build(:registration_payment)).to be_valid
    expect(build(:registration_payment_for_multiple_registrations)).to be_valid
  end
  it "is invalid if registrations aren't for the same camp year" do
    reg_payment = build(:registration_payment_for_multiple_registrations)
    reg_payment.registrations.first.camp = build(:camp, year: 2016)
    expect(reg_payment).to_not be_valid
  end
  context "when there is a discount code" do
    it "has a registration_discount" do
      reg_discount = create(:registration_discount)
      reg_payment = build(:registration_payment, discount_code: reg_discount.code)
      expect(reg_payment.registration_discount).to_not be_nil
    end
  end
  context "when a registration is submitted" do
    let(:stripe_helper) { StripeMock.create_test_helper }
    before { StripeMock.start }
    after { StripeMock.stop }
    it "charges the card and sets the stripe fields" do
      reg_payment = create(:registration_payment, stripe_token: stripe_helper.generate_card_token)
      expect(reg_payment.stripe_charge_id).to_not be_nil
      expect(reg_payment.stripe_brand).to_not be_nil
      expect(reg_payment.stripe_last_four).to_not be_nil
    end
  end
end
