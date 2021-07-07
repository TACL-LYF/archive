class RemoveUniquenessConstraintOnCamperCampIndexInRegistrations < ActiveRecord::Migration[5.2]
  def up
    remove_index :registrations, name: "index_registrations_on_camp_id_and_camper_id"
    add_index :registrations, [:camp_id, :camper_id]
  end

  def down
    remove_index :registrations, name: "index_registrations_on_camp_id_and_camper_id"
    add_index :registrations, [:camp_id, :camper_id], unique: true
  end
end
