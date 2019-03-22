class AddJsonbColumns < ActiveRecord::Migration[5.1]
  def up
    # rename old text columns
    rename_column :registrations, :additional_shirts, :additional_shirts_old
    rename_column :registrations, :camper_involvement, :camper_involvement_old

    # add new jsonb columns and indices
    add_column :registrations, :additional_shirts, :jsonb, null: false, default: {}
    add_column :registrations, :camper_involvement, :jsonb, null: false, default: {}
    add_index  :registrations, :additional_shirts, using: :gin
    add_index  :registrations, :camper_involvement, using: :gin

    def stringToHash(str)
      s = str.sub("--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess\n", "")
      s = s.split("\n").map!{|x| x.split(": ")}
      h = Hash.new
      s.each{|pair| h[pair.first] = pair.last.gsub("'", "")}
      return h
    end

    # find "empty" additional_shirts_old fields and replace with nil
    empty_as = "--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess\nx_small: ''\nsmall: ''\nmedium: ''\nlarge: ''\nx_large: ''\nxx_large: ''\n"
    Registration.where(additional_shirts_old: empty_as).each do |r|
      r.update_attribute("additional_shirts_old", nil)
    end

    # copy nonempty additional_shirts_old to new jsonb column
    Registration.where.not(additional_shirts_old: nil).each do |r|
      r.update_attribute("additional_shirts", stringToHash(r.additional_shirts_old))
    end

    # find "empty" camper_involvement_old fields and replace with nil
    empty_ci = "--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess\nclinic: ''\nlarge_group_icebreaker: ''\nfamily_activity: ''\nnight_market_booth: ''\nbus_monitor: ''\n"
    Registration.where(camper_involvement_old: empty_ci).each do |r|
      r.update_attribute("camper_involvement_old", nil)
    end

    # copy nonempty camper_involvement_old to new jsonb column
    Registration.where.not(camper_involvement_old: nil).each do |r|
      r.update_attribute("camper_involvement", stringToHash(r.camper_involvement_old))
    end
  end

  def down
    remove_column :registrations, :additional_shirts, :jsonb
    remove_column :registrations, :camper_involvement, :jsonb
    rename_column :registrations, :additional_shirts_old, :additional_shirts
    rename_column :registrations, :camper_involvement_old, :camper_involvement
  end
end
