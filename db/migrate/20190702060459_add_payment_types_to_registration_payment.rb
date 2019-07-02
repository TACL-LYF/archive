class AddPaymentTypesToRegistrationPayment < ActiveRecord::Migration[5.1]
  def up
    add_column :registration_payments, :payment_type, :integer, default: 0
    add_column :registration_payments, :check_number, :string
  end
end
