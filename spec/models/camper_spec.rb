require 'rails_helper'

RSpec.describe Camper, type: :model do
  it "has a valid factory" do
    expect(build(:camper)).to be_valid
  end
  it "is invalid without a family" do
    expect(build(:camper, family_id: nil)).to_not be_valid
  end
  it "is invalid without a first name" do
    expect(build(:camper, first_name: nil)).to_not be_valid
  end
  it "is invalid without a last name" do
    expect(build(:camper, last_name: nil)).to_not be_valid
  end
  it "is invalid without a valid birthdate" do
    expect(build(:camper, birthdate: nil)).to_not be_valid
    expect(build(:camper, birthdate: "31-04-2000")).to_not be_valid
  end
  it "is invalid without a gender" do
    expect(build(:camper, gender: nil)).to_not be_valid
  end
  it "is invalid without medical information" do
    expect(build(:camper, medical_conditions_and_medication: nil)).to_not be_valid
  end
  it "is invalid without dietary and allergy information" do
    expect(build(:camper, diet_and_food_allergies: nil)).to_not be_valid
  end
  it "has a valid email address if any" do
    invalid_addresses = %w[user@example,com user_at_foo.org
                           user.name@example.foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |address|
      expect(build(:camper, email: address)).to_not be_valid
    end
  end
  describe "#full_name" do
    it "gets the full name as a string" do
      camper = build(:camper, first_name: "Camper", last_name: "Test")
      expect(camper.full_name).to eq("Camper Test")
    end
  end
  describe "#gender_abbr" do
    it "gets the gender as an abbreviation" do
      camper = build(:camper, gender: "male")
      expect(camper.gender_abbr).to eq("M")
    end
  end
  describe "#normalize_names" do
    it "properly capitalizes names before validating" do
      camper = build(:camper, first_name: "camper", last_name: "test")
      camper.valid?
      expect(camper.first_name).to eq("Camper")
      expect(camper.last_name).to eq("Test")
    end
  end
end
