class AddPreregPaymentFieldsToRegistrationPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :registration_payments, :paid, :boolean, default: false
    RegistrationPayment.all.each{ |rp| rp.update_attribute("paid", true)}
    add_column :registration_payments, :payment_token, :string
    add_index :registration_payments, :payment_token, unique: true
  end
end
