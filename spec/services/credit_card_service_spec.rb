require 'rails_helper'

RSpec.describe CreditCardService do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  it 'creates charges' do
    params = {
      token: stripe_helper.generate_card_token, amount: 50, desc: "Test donation"
    }
    expect(CreditCardService.new(params).charge.charge_succeeded?).to be true
  end

  it 'mocks a declined card error' do
    StripeMock.prepare_card_error(:card_declined)
    params = {
      token: stripe_helper.generate_card_token, amount: 50, desc: "Error"
    }
    expect(CreditCardService.new(params).charge.charge_succeeded?).to be false
  end

  it 'mocks an incorrect number error' do
    StripeMock.prepare_card_error(:incorrect_number)
    params = {
      token: stripe_helper.generate_card_token, amount: 50, desc: "Error"
    }
    expect(CreditCardService.new(params).charge.charge_succeeded?).to be false
  end

  it 'mocks an invalid number error' do
    StripeMock.prepare_card_error(:invalid_number)
    params = {
      token: stripe_helper.generate_card_token, amount: 50, desc: "Error"
    }
    expect(CreditCardService.new(params).charge.charge_succeeded?).to be false
  end

  it 'mocks an invalid expiry month error' do
    StripeMock.prepare_card_error(:invalid_expiry_month)
    params = {
      token: stripe_helper.generate_card_token, amount: 50, desc: "Error"
    }
    expect(CreditCardService.new(params).charge.charge_succeeded?).to be false
  end

  it 'mocks an invalid expiry year error' do
    StripeMock.prepare_card_error(:invalid_expiry_year)
    params = {
      token: stripe_helper.generate_card_token, amount: 50, desc: "Error"
    }
    expect(CreditCardService.new(params).charge.charge_succeeded?).to be false
  end

  it 'mocks an invalid cvc error' do
    StripeMock.prepare_card_error(:invalid_cvc)
    params = {
      token: stripe_helper.generate_card_token, amount: 50, desc: "Error"
    }
    expect(CreditCardService.new(params).charge.charge_succeeded?).to be false
  end

  it 'mocks an expired card error' do
    StripeMock.prepare_card_error(:expired_card)
    params = {
      token: stripe_helper.generate_card_token, amount: 50, desc: "Error"
    }
    expect(CreditCardService.new(params).charge.charge_succeeded?).to be false
  end

  it 'mocks an incorrect cvc error' do
    StripeMock.prepare_card_error(:incorrect_cvc)
    params = {
      token: stripe_helper.generate_card_token, amount: 50, desc: "Error"
    }
    expect(CreditCardService.new(params).charge.charge_succeeded?).to be false
  end

  it 'mocks an incorrect cvc error' do
    StripeMock.prepare_card_error(:incorrect_cvc)
    params = {
      token: stripe_helper.generate_card_token, amount: 50, desc: "Error"
    }
    expect(CreditCardService.new(params).charge.charge_succeeded?).to be false
  end

  it 'mocks a missing error' do
    StripeMock.prepare_card_error(:missing)
    params = {
      token: stripe_helper.generate_card_token, amount: 50, desc: "Error"
    }
    expect(CreditCardService.new(params).charge.charge_succeeded?).to be false
  end

  it 'mocks a processing error' do
    StripeMock.prepare_card_error(:processing_error)
    params = {
      token: stripe_helper.generate_card_token, amount: 50, desc: "Error"
    }
    expect(CreditCardService.new(params).charge.charge_succeeded?).to be false
  end
end
