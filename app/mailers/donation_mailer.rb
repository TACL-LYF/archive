class DonationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.donation_mailer.donation_confirmation.subject
  #
  def donation_confirmation(donation)
    @donation = donation

    mail to: @donation.email,
         bcc: "lyf.treasurer@tacl.org",
         subject: "TACL-LYF Donation Confirmation"
  end
end
