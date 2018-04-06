class AddWaitlistStartsAfterToCamps < ActiveRecord::Migration[5.0]
  def change
    add_column :camps, :waitlist_starts_after, :integer
  end
end
