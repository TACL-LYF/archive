class CreateCampers < ActiveRecord::Migration[5.0]
  def change
    create_table :campers do |t|
      t.string :first_name
      t.string :last_name
      t.datetime :birthdate
      t.integer :gender
      t.string :email
      t.text :medical_conditions_and_medication
      t.text :diet_and_food_allergies
      t.integer :status, default: 0
      t.references :family, foreign_key: true

      t.timestamps
    end
  end
end
