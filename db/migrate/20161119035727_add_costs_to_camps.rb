class AddCostsToCamps < ActiveRecord::Migration[5.0]
  def change
    add_column :camps, :registration_fee, :decimal, precision: 10, scale: 2
    add_column :camps, :shirt_price, :decimal, precision: 6, scale: 2
    add_column :camps, :sibling_discount, :decimal, precision: 6, scale: 2
  end
end
