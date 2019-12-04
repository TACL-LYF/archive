class ChangeDefaultValueForPaymentType < ActiveRecord::Migration[5.1]
  def up
    change_column_default :registration_payments, :payment_type, 1
  end

  def down
    change_column_default :registration_payments, :payment_type, 0
  end
end
