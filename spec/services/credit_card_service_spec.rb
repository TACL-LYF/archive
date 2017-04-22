require 'rails_helper'

RSpec.describe CreditCardService do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  it 'creates charges' do
    params = {
      token: stripe_helper.generate_card_token,
      amount: 50,
      desc: "Test donation"
    }
    expect(CreditCardService.new(params).charge).to be_truthy
  end
end
