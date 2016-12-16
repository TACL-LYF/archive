require "administrate/base_dashboard"

class RegistrationDiscountDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    camp: Field::BelongsTo,
    registration_payment: Field::BelongsTo,
    id: Field::Number,
    code: Field::String,
    discount_percent: Field::Number,
    redeemed: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :camp,
    :code,
    :discount_percent,
    :redeemed,
    :registration_payment,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :camp,
    :code,
    :discount_percent,
    :redeemed,
    :registration_payment,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :camp,
    :code,
    :discount_percent,
  ].freeze

  # Overwrite this method to customize how registration discounts are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(registration_discount)
    "#{registration_discount.code} (#{registration_discount.discount_percent}%)"
  end
end
