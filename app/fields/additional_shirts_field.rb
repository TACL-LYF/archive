require "administrate/field/base"

class AdditionalShirtsField < Administrate::Field::Base
  def to_s
    list = data.reject{ |size, n| n == "" }.
           reduce(""){|str, (size,n)| "#{str}#{size.titlecase.gsub(/^(.+?)\s/){|x| x.upcase}} (#{n}), "}.
           chomp(", ")
    list.blank? ? "None" : list
  end
end
