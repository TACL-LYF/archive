class AddCamperNamesToLastDayPurchases < ActiveRecord::Migration[5.0]
  def change
    add_column :last_day_purchases, :camper_names, :string
  end
end
