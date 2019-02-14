class AddJsonbColumns < ActiveRecord::Migration[5.1]
  def up
    add_column :registrations, :additional_shirts_json, :jsonb, null: false, default: {}
    add_column :registrations, :camper_involvement_json, :jsonb, null: false, default: {}

    add_index  :registrations, :additional_shirts_json, using: :gin
    add_index  :registrations, :camper_involvement_json, using: :gin

    # copy additional_shirts to additional_shirts_json
    empty_as = {"x_small"=>"", "small"=>"", "medium"=>"", "large"=>"", "x_large"=>"", "xx_large"=>""}
    Registration.where(additional_shirts: empty_as).each do |r|
      r.update_attribute("additional_shirts", {})
    end

    Registration.where.not(additional_shirts: nil).each do |r|
      r.update_attribute("additional_shirts_json", JSON.parse(r.additional_shirts.to_json))
    end

    # copy camper_involvement to camper_involvement_json
    empty_ci = {"clinic"=>"", "large_group_icebreaker"=>"", "family_activity"=>"", "night_market_booth"=>"", "bus_monitor"=>""}
    Registration.where(camper_involvement: empty_ci).each do |r|
      r.update_attribute("camper_involvement", {})
    end

    Registration.where.not(camper_involvement: nil).each do |r|
      r.update_attribute("camper_involvement_json", JSON.parse(r.camper_involvement.to_json))
    end
  end

  def down
    remove_column :registrations, :additional_shirts_json, :jsonb
    remove_column :registrations, :camper_involvement_json, :jsonb
  end
end
