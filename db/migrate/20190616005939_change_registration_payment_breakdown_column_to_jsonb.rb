class ChangeRegistrationPaymentBreakdownColumnToJsonb < ActiveRecord::Migration[5.1]
  def up
    rename_column :registration_payments, :breakdown, :breakdown_old
    add_column :registration_payments, :breakdown, :jsonb, null: false, default: {}
  end

  def down
    remove_column :registration_payments, :breakdown, :jsonb
    rename_column :registration_payments, :breakdown_old, :breakdown
  end
end
