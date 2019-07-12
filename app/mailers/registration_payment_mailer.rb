class RegistrationPaymentMailer < ApplicationMailer
  default from: 'lyf@tacl.org'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.registration_payment_mailer.registration_confirmation.subject
  #
  def prereg_confirmation(reg_payment)
    @registrations = reg_payment.registrations
    @family = @registrations.first.camper.family
    @camp = @registrations.first.camp
    @breakdown = reg_payment.breakdown
    if reg_payment.payment_type_card?
      @payment_method = "#{reg_payment.stripe_brand} #{"*"*12}#{reg_payment.stripe_last_four}"
    elsif reg_payment.payment_type_check?
      @payment_method = "Check ##{reg_payment.check_number}"
    else
      @payment_method = ""
    end
    mail to: @family.primary_parent_email,
         cc: @family.secondary_parent_email,
         bcc: "lyf.treasurer@tacl.org",
         subject: "LYF Camp #{@camp.year} Pre-Registration Confirmation"
  end

  def registration_confirmation(reg_payment)
    @registrations = reg_payment.registrations
    @family = @registrations.first.camper.family
    @camp = Camp.first
    @breakdown = reg_payment.breakdown
    @last_four = reg_payment.stripe_last_four
    @brand = reg_payment.stripe_brand
    @is_waitlist = reg_payment.registrations.first.waitlist?
    mail to: @family.primary_parent_email,
         bcc: "lyf.treasurer@tacl.org",
         subject: "LYF Camp #{@camp.year} Registration Confirmation"
  end
end
