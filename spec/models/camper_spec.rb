require 'rails_helper'

describe Camper do
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
  it "is invalid without a birthdate" do
    expect(build(:camper, birthdate: nil)).to_not be_valid
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
end
