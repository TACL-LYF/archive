class AddReturningToCampers < ActiveRecord::Migration[5.0]
  def change
    add_column :campers, :returning, :boolean
  end
end
