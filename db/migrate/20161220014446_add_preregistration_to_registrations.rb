class AddPreregistrationToRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_column :registrations, :preregistration, :boolean, default: false
  end
end
