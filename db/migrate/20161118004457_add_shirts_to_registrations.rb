class AddShirtsToRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_column :registrations, :additional_shirts, :text
  end
end
