class ChangeStripeLastFourColumnsToString < ActiveRecord::Migration[5.1]
  def up
    rename_column :registration_payments, :stripe_last_four, :stripe_last_four_integer
    rename_column :donations, :stripe_last_four, :stripe_last_four_integer
    rename_column :last_day_purchases, :stripe_last_four, :stripe_last_four_integer
    add_column :registration_payments, :stripe_last_four, :string, limit: 4
    add_column :donations, :stripe_last_four, :string, limit: 4
    add_column :last_day_purchases, :stripe_last_four, :string, limit: 4

    RegistrationPayment.all.each do |rp|
      rp.update_columns(stripe_last_four: rp.stripe_last_four_integer.to_s.rjust(4, '0'))
    end

    Donation.all.each do |d|
      d.update_columns(stripe_last_four: d.stripe_last_four_integer.to_s.rjust(4, '0'))
    end

    LastDayPurchase.all.each do |ldp|
      ldp.update_columns(stripe_last_four: ldp.stripe_last_four_integer.to_s.rjust(4, '0'))
    end
  end

  def down
    remove_column :registration_payments, :stripe_last_four, :string
    remove_column :donations, :stripe_last_four, :string
    remove_column :last_day_purchases, :stripe_last_four, :string
    rename_column :registration_payments, :stripe_last_four_integer, :stripe_last_four
    rename_column :donations, :stripe_last_four_integer, :stripe_last_four
    rename_column :last_day_purchases, :stripe_last_four_integer, :stripe_last_four
  end
end
