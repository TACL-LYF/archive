class RegistrationPaymentMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.registration_payment_mailer.registration_confirmation.subject
  #
  def registration_confirmation(reg_payment)
    @registrations = reg_payment.registrations
    @family = @registrations.first.camper.family
    @camp = Camp.first
    @breakdown = reg_payment.breakdown
    @last_four = reg_payment.stripe_last_four
    @brand = reg_payment.stripe_brand
    @is_waitlist = reg_payment.registrations.first.waitlist?
    mail to: @family.primary_parent_email,
         bcc: "lyf.od@tacl.org",
         subject: "LYF Camp #{@camp.year} Registration Confirmation"
  end
end
