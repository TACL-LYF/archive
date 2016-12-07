class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  SHIRT_SIZES = [:x_small, :small, :medium, :large, :x_large, :xx_large]
  CAMPER_ROLES = [:clinic, :large_group_icebreaker, :family_activity, :night_market_booth, :bus_monitor]
end
