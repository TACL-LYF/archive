class LastDayPurchasesController < ApplicationController
  def new
    @last_day_purchase = LastDayPurchase.new
  end

  def create
    @last_day_purchase = LastDayPurchase.new(last_day_purchase_params)
    # begin
      if @last_day_purchase.save
        LastDayPurchaseMailer.last_day_purchase_confirmation(@last_day_purchase).deliver_now
        redirect_to last_day_purchase_confirmation_path
      else
        render 'new'
      end
    # rescue => e
    #   logger.warn "Error submitting form"
    #   logger.warn e
    #   flash.now[:danger] = "Something went wrong."
    #   render 'new'
    # end
  end

  def confirm
    render 'confirm'
  end

  private
    def last_day_purchase_params
      params.require(:last_day_purchase).permit(:first_name, :last_name, :address, :city,
        :state, :zip, :email, :phone, :amount, :dollar_for_dollar,
        :company, :stripe_token)
    end
end
