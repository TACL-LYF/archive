class DonationsController < ApplicationController
  def new
    @donation = Donation.new
  end

  def create
    @donation = Donation.new(donation_params)
    begin
      if @donation.save
        session[:donation_id] = @donation.id
        DonationMailer.donation_confirmation(@donation).deliver_now
        redirect_to donation_confirmation_path
      else
        render 'new'
      end
    rescue => e
      logger.warn "Error submitting donation form"
      logger.warn e
      flash.now[:danger] = "Something went wrong."
      render 'new'
    end
  end

  def confirm
    @donation = Donation.find(session[:donation_id])
  end

  private
    def donation_params
      params.require(:donation).permit(:first_name, :last_name, :address, :city,
        :state, :zip, :email, :phone, :amount, :other_amount, :company_match,
        :company, :stripe_token)
    end
end
