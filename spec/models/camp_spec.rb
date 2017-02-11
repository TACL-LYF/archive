require 'rails_helper'

RSpec.describe Camp, type: :model do
  it "has a valid factory" do
    expect(build(:camp)).to be_valid
  end
  it "is invalid without a year" do
    expect(build(:camp, year: nil)).to_not be_valid
  end
end
