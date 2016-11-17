class CreateReferralMethods < ActiveRecord::Migration[5.0]
  def change
    create_table :referral_methods do |t|
      t.string :name
      t.boolean :allow_details

      t.timestamps
    end

    add_reference :referrals, :referral_method, foreign_key: true
    add_index :referrals, [:family_id, :referral_method_id], unique: true
  end
end
