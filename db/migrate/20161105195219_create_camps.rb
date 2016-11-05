class CreateCamps < ActiveRecord::Migration[5.0]
  def change
    create_table :camps do |t|
      t.string :name
      t.integer :year

      t.timestamps
    end
    add_index :camps, :year, unique: true
  end
end
