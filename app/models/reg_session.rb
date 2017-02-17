class RegSession < ApplicationRecord
  store :data, accessors: [:family, :campers, :regs, :camper, :reg, :payment]
end
