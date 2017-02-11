require 'rails_helper'

RSpec.describe Family, type: :model do
  it "has a valid factory" do
    expect(build(:family)).to be_valid
  end
  it "is invalid without a primary parent first name" do
    expect(build(:family, primary_parent_first_name: nil)).to_not be_valid
  end
  it "is invalid without a primary parent last name" do
    expect(build(:family, primary_parent_last_name: nil)).to_not be_valid
  end
  it "is invalid without a primary parent valid email address" do
    expect(build(:family, primary_parent_email: nil)).to_not be_valid
    invalid_addresses = %w[user@example,com user_at_foo.org
                           user.name@example.foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |address|
      expect(build(:family, primary_parent_email: address)).to_not be_valid
    end
  end
  it "is invalid without a valid primary parent phone number" do
    expect(build(:family, primary_parent_phone_number: nil)).to_not be_valid
  end
  it "is invalid without all required address fields" do
    expect(build(:family, street: nil)).to_not be_valid
    expect(build(:family, city: nil)).to_not be_valid
    expect(build(:family, state: nil)).to_not be_valid
    expect(build(:family, zip: nil)).to_not be_valid
  end

  describe "#primary_parent" do
    it "gets the primary parent's full name as a string" do
      family = build(:family, primary_parent_first_name: "Primary",
                     primary_parent_last_name: "Parent")
      expect(family.primary_parent).to eq("Primary Parent")
    end
  end

  describe "#secondary_parent" do
    it "gets the secondary parent's full name as a string" do
      family = build(:family, secondary_parent_first_name: "Secondary",
                     secondary_parent_last_name: "Parent")
      expect(family.secondary_parent).to eq("Secondary Parent")
    end
  end

  describe "#normalize_names" do
    it "properly capitalizes name and address fields before validating" do
      family = build(:family, primary_parent_first_name: "primary",
                              primary_parent_last_name: "parent",
                              secondary_parent_first_name: "secondary",
                              secondary_parent_last_name: "parent",
                              street: "oak ave.", suite: "apt. 201",
                              city: "fremont", state: "ca")
      family.valid?
      expect(family.primary_parent_first_name).to eq("Primary")
      expect(family.primary_parent_last_name).to eq("Parent")
      expect(family.secondary_parent_first_name).to eq("Secondary")
      expect(family.secondary_parent_last_name).to eq("Parent")
      expect(family.street).to eq("Oak Ave.")
      expect(family.suite).to eq("Apt. 201")
      expect(family.city).to eq("Fremont")
      expect(family.state).to eq("CA")
    end
  end
end
