class AddDiscountTypeToRegistrationDiscounts < ActiveRecord::Migration[5.1]
  def up
    add_column :registration_discounts, :discount_type, :integer, default: 0
    RegistrationDiscount.all.each{ |rd| rd.update_columns(discount_type: 1)}
    add_column :registration_discounts, :description, :string
    rename_column :registration_discounts, :discount_percent, :discount_amount
  end

  def down
    remove_column :registration_discounts, :discount_type, :integer
    remove_column :registration_discounts, :description, :string
    rename_column :registration_discounts, :discount_amount, :discount_percent
  end
end
