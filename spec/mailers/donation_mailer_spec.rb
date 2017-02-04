require "rails_helper"

RSpec.describe DonationMailerMailer, type: :mailer do
  describe "donation_confirmation" do
    let(:mail) { DonationMailerMailer.donation_confirmation }

    it "renders the headers" do
      expect(mail.subject).to eq("Donation confirmation")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
