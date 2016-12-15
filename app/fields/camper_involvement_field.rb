require "administrate/field/base"

class CamperInvolvementField < Administrate::Field::Base
  def to_s
    data.keys.map(&:titlecase).join(', ')
  end
end
