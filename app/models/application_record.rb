class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  SHIRT_SIZES = [:x_small, :small, :medium, :large, :x_large, :xx_large]
  CAMPER_ROLES = [:clinic, :large_group_icebreaker, :family_activity, :night_market_booth, :bus_monitor]

  DATES_FOR_SELECT = (1..31).to_a.unshift(["Day", nil])
  MONTHS_FOR_SELECT = [
    ["Month", nil],
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ]
  CAMPER_BIRTH_YEARS_FOR_SELECT = ((Date.current.year-20)..(Date.current.year-12)).to_a.unshift(["Year", nil])
  CURRENT_YEARS_FOR_SELECT = ((Date.current.year-5)..(Date.current.year+5)).to_a.unshift(["Year", nil])
end
