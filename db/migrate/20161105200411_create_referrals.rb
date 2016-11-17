class CreateReferrals < ActiveRecord::Migration[5.0]
  def change
    create_table :referrals do |t|
      t.string :details
      t.references :family, foreign_key: true

      t.timestamps
    end
  end
end
