require 'rails_helper'

RSpec.describe LastDayPurchasesController, type: :controller do

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

      it "creates the purchase" do
        expect { post :create,
          params: {last_day_purchase: attributes_for(:last_day_purchase).merge(stripe_token: stripe_helper.generate_card_token) }}
          .to change {LastDayPurchase.count }.by(1)
      end
      it "redirects to the confirmation page" do
        post :create,
          params: { last_day_purchase: attributes_for(:last_day_purchase).merge(stripe_token: stripe_helper.generate_card_token) }
        expect(response).to redirect_to last_day_purchase_confirmation_path
      end
    end

    context "with invalid attributes" do
      let(:stripe_helper) { StripeMock.create_test_helper }
      before { StripeMock.start }
      after { StripeMock.stop }

      it "does not create the purhase" do
        expect { post :create,
          params: { last_day_purchase: attributes_for(:last_day_purchase, email: nil).merge(stripe_token: stripe_helper.generate_card_token) }}
          .to_not change { LastDayPurchase.count }
      end
      it "re-renders the new view" do
        post :create,
          params: { last_day_purchase: attributes_for(:last_day_purchase, first_name: nil).merge(stripe_token: stripe_helper.generate_card_token) }
        expect(response).to render_template("new")
      end
    end
  end
end
