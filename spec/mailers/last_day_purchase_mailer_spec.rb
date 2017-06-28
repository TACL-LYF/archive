require "rails_helper"

RSpec.describe LastDayPurchaseMailer, type: :mailer do
  describe "last_day_purchase_confirmation" do
    let(:last_day_purchase) { build(:last_day_purchase, amount: "50.00") }
    let(:mail) { LastDayPurchaseMailer.last_day_purchase_confirmation(last_day_purchase) }

    it "renders the subject" do
      expect(mail.subject).to eq("TACL-LYF Last Day Purchases Confirmation")
    end
    it "renders the receiver email" do
      expect(mail.to).to eq(["#{last_day_purchase.email}"])
    end
    it "renders the sender email" do
      expect(mail.from).to eq(["lyf@tacl.org"])
    end
    it "renders the bcc email" do
      expect(mail.bcc).to eq(["lyf.treasurer@tacl.org"])
    end

    it "renders the purchase amount" do
      expect(mail.body.encoded).to match(last_day_purchase.amount.to_s)
    end

    it "renders the last 4 digits of the charged card" do
      expect(mail.body.encoded).to match("#{last_day_purchase.stripe_last_four}")
    end
  end

end
