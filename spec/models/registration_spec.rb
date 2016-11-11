require 'rails_helper'

describe Registration do
  it "has a valid factory" do
    expect(build(:registration)).to be_valid
  end
  it "is invalid without a camper" do
    expect(build(:registration, camper_id: nil)).to_not be_valid
  end
  it "is invalid without a camp" do
    expect(build(:registration, camp_id: nil)).to_not be_valid
  end
  it "is invalid without a grade" do
    expect(build(:registration, grade: nil)).to_not be_valid
  end
  it "is invalid without a shirt size" do
    expect(build(:registration, shirt_size: nil)).to_not be_valid
  end
  it "is invalid without a bus option" do
    expect(build(:registration, bus: nil)).to_not be_valid
  end
  it "is invalid without a waiver signature" do
    expect(build(:registration, waiver_signature: nil)).to_not be_valid
  end
  it "is invalid without a waiver date" do
    expect(build(:registration, waiver_date: nil)).to_not be_valid
  end
end
