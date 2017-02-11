require "rails_helper"

RSpec.describe RegistrationPaymentMailer, type: :mailer do
  describe "registration_confirmation" do
    let(:reg_payment) { build(:registration_payment) }
    let(:mail) { RegistrationPaymentMailer.registration_confirmation(reg_payment) }

    it "renders the subject" do
      expect(mail.subject).to eq("LYF Camp 2017 Registration Confirmation")
    end
    it "renders the receiver email" do
      expect(mail.to).to eq(["#{reg_payment.registrations.first.camper.family.primary_parent_email}"])
    end
    it "renders the sender email" do
      expect(mail.from).to eq(["lyf@tacl.org"])
    end
    it "renders the bcc email" do
      expect(mail.bcc).to eq(["lyf.od@tacl.org"])
    end

    it "renders the total amount charged" do
      expect(mail.body.encoded).to match(reg_payment.total.to_s)
    end

    it "renders the last 4 digits of the charged card" do
      expect(mail.body.encoded).to match("#{reg_payment.stripe_last_four}")
    end

    it "renders each camper registered" do
      reg_payment.registrations.each do |reg|
        expect(mail.body.encoded).to match(reg.camper.full_name)
      end
    end
  end

end
