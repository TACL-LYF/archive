class CreateRegistrationPayments < ActiveRecord::Migration[5.0]
  def change
    create_table :registration_payments do |t|
      t.decimal :total, precision: 10, scale: 2
      t.decimal :additional_donation, precision: 10, scale: 2
      t.string :discount_code
      t.string :stripe_token

      t.timestamps
    end

    add_reference :registrations, :registration_payment, foreign_key: true
  end
end
