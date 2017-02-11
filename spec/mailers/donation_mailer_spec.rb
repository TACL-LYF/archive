require "rails_helper"

RSpec.describe DonationMailer, type: :mailer do
  describe "donation_confirmation" do
    let(:donation) { build(:donation, amount: "50.00") }
    let(:mail) { DonationMailer.donation_confirmation(donation) }

    it "renders the subject" do
      expect(mail.subject).to eq("TACL-LYF Donation Confirmation")
    end
    it "renders the receiver email" do
      expect(mail.to).to eq(["#{donation.email}"])
    end
    it "renders the sender email" do
      expect(mail.from).to eq(["lyf@tacl.org"])
    end
    it "renders the bcc email" do
      expect(mail.bcc).to eq(["lyf.treasurer@tacl.org"])
    end

    it "renders the donation amount" do
      expect(mail.body.encoded).to match(donation.amount.to_s)
    end

    it "does not include text about a donation receipt" do
      expect(mail.body.encoded)
        .to_not match("donation receipt for charitable tax deductions")
    end

    context "when the donation amount > 100" do
      let (:donation) { build(:donation, amount: "100.00") }
      it "includes text about a donation receipt" do
        expect(mail.body.encoded)
          .to match("donation receipt for charitable tax deductions")
      end
    end
  end

end
