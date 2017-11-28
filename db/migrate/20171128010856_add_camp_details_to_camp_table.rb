class AddCampDetailsToCampTable < ActiveRecord::Migration[5.0]
  def change
    add_column :camps, :camp_start_date, :date
    add_column :camps, :camp_end_date, :date
    add_column :camps, :campsite, :string
    add_column :camps, :campsite_address, :string
  end
end
