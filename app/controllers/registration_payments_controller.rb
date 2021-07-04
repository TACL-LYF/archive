class RegistrationPaymentsController < ApplicationController
  def show
    @reg_payment = RegistrationPayment.find_by_payment_token(params[:payment_token])
    @camp = @reg_payment.registrations.first.camp
  end

  def update
    @reg_payment = RegistrationPayment.find_by_payment_token(regpayment_params[:payment_token])
    @reg_payment.payment_type = :card
    @reg_payment.stripe_token = regpayment_params[:stripe_token]
    begin
      if @reg_payment.save!
        RegistrationPaymentMailer.prereg_confirmation(@reg_payment).deliver_now
        flash[:info] = "Your payment has been completed!"
        redirect_to registration_payment_path
      else
        render 'show'
      end
    rescue => e
      logger.warn "Error submitting pre-registration payment"
      logger.warn e
      msg = "Sorry, something went wrong. Please refresh the page and try again."
      msg += " If the problem persists, please email us at lyf@tacl.org."
      flash.now[:danger] = msg
      render 'show'
    end
  end

  private
    def regpayment_params
      params.permit(:utf8, :_method, :authenticity_token, :payment_token, :stripe_token)
    end
end
