class AddCampPreferenceToRegistrations < ActiveRecord::Migration[5.2]
  def up
    add_column :registrations, :camp_preference, :integer, default: 0
  end

  def down
    remove_column :registrations, :camp_preference, :integer
  end
end
