class AddStripeColumnsToRegistrationPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :registration_payments, :stripe_brand, :string
    add_column :registration_payments, :stripe_last_four, :integer
  end
end
