class CreateFamilies < ActiveRecord::Migration[5.0]
  def change
    create_table :families do |t|
      t.string :primary_parent_first_name
      t.string :primary_parent_last_name
      t.string :primary_parent_email
      t.string :primary_parent_phone_number
      t.string :secondary_parent_first_name
      t.string :secondary_parent_last_name
      t.string :secondary_parent_email
      t.string :secondary_parent_phone_number
      t.string :suite
      t.string :street
      t.string :city
      t.string :state
      t.string :zip

      t.timestamps
    end
  end
end
