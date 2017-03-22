require 'rails_helper'

RSpec.describe Registration, type: :model do
  it "has a valid factory" do
    expect(build(:registration)).to be_valid
  end
  it "is invalid without a camper" do
    expect(build(:registration, camper_id: nil)).to_not be_valid
  end
  it "is invalid without a camp" do
    expect(build(:registration, camp_id: nil)).to_not be_valid
  end
  it "is invalid without a grade in the accepted range" do
    [nil, 2, 13].each do |g|
      expect(build(:registration, grade: g)).to_not be_valid
    end
  end
  it "is invalid without a shirt size" do
    expect(build(:registration, shirt_size: nil)).to_not be_valid
  end
  it "is invalid without a bus option" do
    expect(build(:registration, bus: nil)).to_not be_valid
  end
  it "is invalid without a waiver signature matching the primary parent name" do
    expect(build(:registration, waiver_signature: nil)).to_not be_valid
    expect(build(:registration, waiver_signature: "invalid")).to_not be_valid
  end
  it "is invalid without a waiver date within 1 day of the current date" do
    expect(build(:registration, waiver_date: nil)).to_not be_valid
    expect(build(:registration, waiver_date: Time.zone.today-2)).to_not be_valid
  end

  describe "#total_additional_shirts" do
    context "without additional shirts" do
      it "returns 0" do
        expect(build(:registration).total_additional_shirts).to eq(0)
      end
    end
    context "with additional shirts" do
      it "adds up the total number of additional shirts across all sizes" do
        reg = build(:registration, x_small: 1, small: 2, medium: 3, large: 4,
                    x_large: 5, xx_large: 6)
        expect(reg.total_additional_shirts).to eq(21)
      end
    end
  end

  describe "#list_additional_shirts" do
    context "without additional shirts" do
      it "prints \"None\"" do
        expect(build(:registration).list_additional_shirts).to eq("None")
      end
    end
    context "with additional shirts" do
      it "gets a list of all additional shirts and quantities" do
        reg = build(:registration, x_small: 1, small: 2, medium: 3, large: 4,
                    x_large: 5, xx_large: 6)
        expect(reg.list_additional_shirts).to include("X Small (1)", "Small (2)",
          "Medium (3)", "Large (4)", "X Large (5)", "XX Large (6)", ", ")
      end
    end
  end

  describe "#list_camper_involvement" do
    context "without any roles" do
      it "prints \"None\"" do
        expect(build(:registration).list_camper_involvement).to eq("None")
      end
    end
    context "with one or more roles" do
      it "gets a comma-separated list of the roles the camper is interested in" do
        reg = build(:registration, clinic: true, night_market_booth: true,
          large_group_icebreaker: true, family_activity: true, bus_monitor: true)
        expect(reg.list_camper_involvement).to include("Large Group Icebreaker",
          "Clinic", "Bus Monitor", "Night Market Booth", "Family Activity", ", ")
      end
    end
  end
end
