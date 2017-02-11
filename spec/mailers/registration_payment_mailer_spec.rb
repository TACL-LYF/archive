require "rails_helper"

RSpec.describe RegistrationPaymentMailer, type: :mailer do
  describe "registration_confirmation" do
    let(:reg_payment) { build(:registration_payment) }
    let(:mail) { RegistrationPaymentMailer.registration_confirmation(reg_payment) }

    it "renders the headers" do
      expect(mail.subject).to eq("LYF Camp 2017 Registration Confirmation")
      expect(mail.to).to eq(["#{reg_payment.registrations.first.camper.family.primary_parent_email}"])
      expect(mail.from).to eq(["lyf@tacl.org"])
      expect(mail.bcc).to eq(["lyf.od@tacl.org"])
    end

    it "renders the body"
  end

end
