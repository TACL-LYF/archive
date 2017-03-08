require "administrate/base_dashboard"

class RegistrationPaymentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    registrations: Field::HasMany,
    registration_discount: Field::HasOne,
    id: Field::Number,
    total: Field::Number.with_options(searchable: false, prefix: '$', decimals: 2),
    additional_donation: Field::Number.with_options(searchable: false, prefix: '$', decimals: 2),
    discount_code: Field::String,
    stripe_charge_id: Field::String,
    breakdown: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    stripe_brand: Field::String,
    stripe_last_four: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :registrations,
    :registration_discount,
    :additional_donation,
    :total,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :additional_donation,
    :registration_discount,
    :total,
    :registrations,
    :stripe_charge_id,
    :stripe_brand,
    :stripe_last_four,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :registrations,
    :registration_discount,
    :total,
    :additional_donation,
    :discount_code,
    :stripe_charge_id,
    :stripe_brand,
    :stripe_last_four,
  ].freeze

  # Overwrite this method to customize how registration payments are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(registration_payment)
  #   "RegistrationPayment ##{registration_payment.id}"
  # end
end
