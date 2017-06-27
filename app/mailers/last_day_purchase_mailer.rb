class LastDayPurchaseMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.donation_mailer.donation_confirmation.subject
  #
  def last_day_purchase_confirmation(last_day_purchase)
    @last_day_purchase = last_day_purchase

    mail to: @last_day_purchase.email,
         bcc: "lyf.treasurer@tacl.org",
         subject: "TACL-LYF Last Day Purchases Confirmation"
  end
end
