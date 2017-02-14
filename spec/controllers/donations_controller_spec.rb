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
      it "creates the donation"# do
      #   expect { post :create, donation: attributes_for(:donation) }
      #     .to change { Donation.count }.by(1)
      # end
      it "sets the donation id in the session"
      it "renders to the donation confirmation page"
    end

    context "with invalid attributes" do
      it "does not create the donation"
      it "re-renders the new view with error messages"
    end
  end
end
