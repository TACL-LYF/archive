class AddCamperInvolvementToRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_column :registrations, :camper_involvement, :text
  end
end
