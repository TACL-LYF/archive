class CreateDonations < ActiveRecord::Migration[5.0]
  def change
    create_table :donations do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :street
      t.string :suite
      t.string :city
      t.string :state
      t.string :zip
      t.decimal :amount,  precision: 10, scale: 2
      t.string :stripe_charge_id
      t.string :stripe_brand
      t.integer :stripe_last_four

      t.timestamps
    end
  end
end
