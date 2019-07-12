class RegistrationPaymentsController < ApplicationController
  def show
    @reg_payment = RegistrationPayment.find_by_payment_token(params[:payment_token])
  end

  def update
    @reg_payment = RegistrationPayment.find_by_payment_token(process_params[:payment_token])
    @reg_payment.stripe_token = process_params[:stripe_token]
    begin
      if @reg_payment.save
        # TODO: send a confirmation email
        flash[:notice] = "You have successfully pre-registered!"
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
    def process_params
      params.permit(:payment_token, :stripe_token)
    end
end
