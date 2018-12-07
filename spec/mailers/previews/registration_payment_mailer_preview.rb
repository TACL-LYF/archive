# Preview all emails at http://localhost:3000/rails/mailers/registration_payment_mailer
class RegistrationPaymentMailerPreview < ActionMailer::Preview

  # Preview this email at
  # http://localhost:3000/rails/mailers/registration_payment_mailer/registration_confirmation
  def registration_confirmation
    reg_payment = RegistrationPayment.find(92)
    RegistrationPaymentMailer.registration_confirmation(reg_payment)
  end
end
