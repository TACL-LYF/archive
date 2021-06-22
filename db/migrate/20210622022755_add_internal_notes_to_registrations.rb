class AddInternalNotesToRegistrations < ActiveRecord::Migration[5.2]
  def up
    add_column :registrations, :internal_notes, :text
  end

  def down
    remove_column :registrations, :internal_notes, :text
  end
end
