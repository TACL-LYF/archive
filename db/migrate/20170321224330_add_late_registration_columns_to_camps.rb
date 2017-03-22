class AddLateRegistrationColumnsToCamps < ActiveRecord::Migration[5.0]
  def change
    add_column :camps, :registration_late_fee, :decimal, precision: 6, scale: 2
    add_column :camps, :registration_open_date, :date
    add_column :camps, :registration_late_date, :date
    add_column :camps, :registration_close_date, :date
  end
end
