require "administrate/base_dashboard"

class CampDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    registrations: Field::HasMany,
    registration_discounts: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    year: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    registration_fee: Field::Number.with_options(searchable: false, prefix: "$", decimals: 2),
    shirt_price: Field::Number.with_options(searchable: false, prefix: "$", decimals: 2),
    sibling_discount: Field::Number.with_options(searchable: false, prefix: "$", decimals: 2),
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :year,
    :name,
    :registrations,
    :registration_discounts,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :year,
    :name,
    :registration_fee,
    :shirt_price,
    :sibling_discount,
    :registrations,
    :registration_discounts,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :year,
    :name,
    :registration_fee,
    :shirt_price,
    :sibling_discount,
  ].freeze

  # Overwrite this method to customize how camps are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(camp)
    "#{camp.year}"
  end
end
