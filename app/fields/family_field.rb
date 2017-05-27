require "administrate/field/base"

class FamilyField < Administrate::Field::Base
  def to_s
    "#{data.primary_parent_first_name} #{data.primary_parent_last_name}"
  end
end
