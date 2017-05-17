class RegistrationPaymentMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.registration_payment_mailer.registration_confirmation.subject
  #
  def registration_confirmation(reg_payment)
    @camp = Camp.first
    @breakdown = reg_payment.breakdown
    @last_four = reg_payment.stripe_last_four
    @brand = reg_payment.stripe_brand
    mail to: reg_payment.registrations.first.camper.family.primary_parent_email,
         bcc: "lyf.od@tacl.org",
         subject: "LYF Camp 2017 Registration Confirmation"
  end
end
