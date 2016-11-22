class CreateRegistrationDiscounts < ActiveRecord::Migration[5.0]
  def change
    create_table :registration_discounts do |t|
      t.string :code
      t.integer :discount_percent
      t.boolean :redeemed, null: false, default: false
      t.references :camp, foreign_key: true
      t.references :registration_payment, foreign_key: true

      t.timestamps
    end
  end
end
