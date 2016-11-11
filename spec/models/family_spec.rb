require 'rails_helper'

describe Family do
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
  it "is invalid without a primary parent phone number" do
    expect(build(:family, primary_parent_phone_number: nil)).to_not be_valid
  end
  it "is invalid without all required address fields" do
    expect(build(:family, street: nil)).to_not be_valid
    expect(build(:family, city: nil)).to_not be_valid
    expect(build(:family, state: nil)).to_not be_valid
    expect(build(:family, zip: nil)).to_not be_valid
  end
end
