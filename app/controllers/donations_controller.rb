class DonationsController < ApplicationController
  def new
    @donation = Donation.new
  end

  def create
    @donation = Donation.new(donation_params)
    begin
      if @donation.save!
        session[:donation_id] = @donation.id
        DonationMailer.donation_confirmation(@donation).deliver_now
        redirect_to donation_confirmation_path
      else
        render 'new'
      end
    rescue Stripe::CardError => e
      msg = log_error_and_return(e)
      flash.now[:danger] = "There was a problem processing your payment: #{msg}"
      render 'new'
    rescue Stripe::RateLimitError => e
      # Too many requests made to the API too quickly
      msg = log_error_and_return(e)
      flash.now[:danger] = "There was a problem processing your payment: #{msg} Please try again in a bit."
      render 'new'
    rescue Stripe::InvalidRequestError => e
      # Invalid parameters were supplied to Stripe's API
      msg = log_error_and_return(e)
      flash.now[:danger] = "There was a problem processing your payment: #{msg}"
      render 'new'
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      # (maybe you changed API keys recently)
      msg = log_error_and_return(e)
      flash.now[:danger] = "There was a problem processing your payment: #{msg}"
      render 'new'
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed
      msg = log_error_and_return(e)
      flash.now[:danger] = "There was a problem processing your payment: #{msg}"
      render 'new'
    rescue Stripe::StripeError => e
      # Display a very generic error to the user, and maybe send
      # yourself an email
      msg = log_error_and_return(e)
      flash.now[:danger] = "There was a problem processing your payment."
      render 'new'
    rescue Exceptions::AmexError => e
      logger.warn "Amex card submitted"
      flash.now[:danger] = "Sorry, we do not accept American Express"
      render 'new'
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

    def log_error_and_return(e)
      err = e.json_body[:error]
      logger.warn "Status is: #{e.http_status}"
      logger.warn "Type is: #{err[:type]}"
      logger.warn "Code is: #{err[:code]}"
      logger.warn "Param is: #{err[:param]}"
      logger.warn "Message is: #{err[:message]}"
      return err[:message]
    end
end
