class ChangeRegistrationsCancelledToStatus < ActiveRecord::Migration[5.0]
  def change
    remove_column :registrations, :cancelled
    add_column :registrations, :status, :integer, null: false, default: 0
  end
end
