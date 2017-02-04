# Preview all emails at http://localhost:3000/rails/mailers/donation_mailer
class DonationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/donation_mailer/donation_confirmation
  def donation_confirmation
    donation = Donation.last
    DonationMailer.donation_confirmation(donation)
  end

end
