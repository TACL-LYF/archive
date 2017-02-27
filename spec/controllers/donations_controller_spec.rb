require 'rails_helper'

RSpec.describe DonationsController, type: :controller do

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      let(:stripe_helper) { StripeMock.create_test_helper }
      before { StripeMock.start }
      after { StripeMock.stop }

      it "creates the donation" do
        expect { post :create,
          params: { donation: attributes_for(:donation).merge(stripe_token: stripe_helper.generate_card_token) }}
          .to change { Donation.count }.by(1)
      end
      it "sets the donation_id in the session" do
        post :create,
          params: { donation: attributes_for(:donation).merge(stripe_token: stripe_helper.generate_card_token) }
        expect(session[:donation_id]).to_not be_nil
      end
      it "redirects to the confirmation page" do
        post :create,
          params: { donation: attributes_for(:donation).merge(stripe_token: stripe_helper.generate_card_token) }
        expect(response).to redirect_to donation_confirmation_path
      end
    end

    context "with invalid attributes" do
      let(:stripe_helper) { StripeMock.create_test_helper }
      before { StripeMock.start }
      after { StripeMock.stop }

      it "does not create the donation" do
        expect { post :create,
          params: { donation: attributes_for(:donation, email: nil).merge(stripe_token: stripe_helper.generate_card_token) }}
          .to_not change { Donation.count }
      end
      it "re-renders the new view" do
        post :create,
          params: { donation: attributes_for(:donation, first_name: nil).merge(stripe_token: stripe_helper.generate_card_token) }
        expect(response).to render_template("new")
      end
    end
  end
end
