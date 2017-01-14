class DonationsController < ApplicationController
  def new
    @donation = Donation.new
  end

  def create
    @donation = Donation.new(donation_params)
    if @donation.save
    else
      render 'new'
    end
  end

  private
    def donation_params
      params.require(:donation).permit(:first_name, :last_name, :address, :city,
        :state, :zip, :email, :phone, :amount, :stripe_card_token)
    end
end
