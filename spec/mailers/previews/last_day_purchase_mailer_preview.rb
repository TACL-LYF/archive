# Preview all emails at http://localhost:3000/rails/mailers/last_day_purchase_mailer
class LastDayPurchaseMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/last_day_purchase_mailer/last_day_purchase_confirmation
  def last_day_purchase_confirmation
    last_day_purchase = LastDayPurchase.last
    LastDayPurchaseMailer.last_day_purchase_confirmation(last_day_purchase)
  end

end
