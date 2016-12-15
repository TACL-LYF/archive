require "administrate/field/base"

class ShirtSizeField < Administrate::Field::Base
  def to_s
    data.titlecase.gsub(/^(.+?)\s/){|x| x.upcase}
  end
end
