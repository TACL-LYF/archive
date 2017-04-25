class AddCancelledToRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_column :registrations, :cancelled, :boolean, null: false, default: false
  end
end
