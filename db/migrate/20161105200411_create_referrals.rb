class CreateReferrals < ActiveRecord::Migration[5.0]
  def change
    create_table :referrals do |t|
      t.integer :id
      t.integer :referral_method_id
      t.integer :family_id
      t.string :details

      t.timestamps
    end
  end
end
