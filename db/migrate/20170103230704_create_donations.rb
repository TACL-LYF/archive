class CreateDonations < ActiveRecord::Migration[5.0]
  def change
    create_table :donations do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.decimal :amount,  precision: 10, scale: 2
      t.boolean :company_match
      t.string :company
      t.string :stripe_charge_id
      t.string :stripe_brand
      t.integer :stripe_last_four

      t.timestamps
    end
  end
end
