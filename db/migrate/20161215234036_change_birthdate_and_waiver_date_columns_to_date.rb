class ChangeBirthdateAndWaiverDateColumnsToDate < ActiveRecord::Migration[5.0]
  def up
    change_column :campers, :birthdate, :date
    change_column :registrations, :waiver_date, :date
  end

  def down
    change_column :campers, :birthdate, :datetime
    change_column :registrations, :waiver_date, :datetime
  end
end
