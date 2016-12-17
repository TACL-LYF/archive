class AddDetailsFieldLabelToReferralMethod < ActiveRecord::Migration[5.0]
  def change
    add_column :referral_methods, :details_field_label, :string, default: "Please specify:"
  end
end
