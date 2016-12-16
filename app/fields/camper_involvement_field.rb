require "administrate/field/base"

class CamperInvolvementField < Administrate::Field::Base
  def to_s
    data.reject{|k,v| v.blank?}.keys.map(&:titlecase).join(', ')
  end
end
