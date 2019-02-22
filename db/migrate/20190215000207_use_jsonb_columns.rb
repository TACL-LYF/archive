class UseJsonbColumns < ActiveRecord::Migration[5.1]
  def up
    rename_column :registrations, :additional_shirts, :additional_shirts_old
    rename_column :registrations, :additional_shirts_json, :additional_shirts
    rename_column :registrations, :camper_involvement, :camper_involvement_old
    rename_column :registrations, :camper_involvement_json, :camper_involvement
  end

  def down
    rename_column :registrations, :camper_involvement, :camper_involvement_json
    rename_column :registrations, :camper_involvement_old, :camper_involvement
    rename_column :registrations, :additional_shirts, :additional_shirts_json
    rename_column :registrations, :additional_shirts_old, :additional_shirts
  end
end
