require "administrate/base_dashboard"

class DonationDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    first_name: Field::String,
    last_name: Field::String,
    email: Field::String,
    phone: Field::String,
    address: Field::String,
    city: Field::String,
    state: Field::String,
    zip: Field::String,
    amount: Field::String.with_options(searchable: false),
    company_match: Field::Boolean,
    company: Field::String,
    stripe_charge_id: Field::String,
    stripe_brand: Field::String,
    stripe_last_four: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :created_at,
    :first_name,
    :last_name,
    :email,
    :phone,
    :address,
    :city,
    :state,
    :zip,
    :amount,
    :company_match,
    :company,
    :stripe_brand,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :first_name,
    :last_name,
    :email,
    :phone,
    :address,
    :city,
    :state,
    :zip,
    :amount,
    :company_match,
    :company,
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
    :first_name,
    :last_name,
    :email,
    :phone,
    :address,
    :city,
    :state,
    :zip,
    :amount,
    :company_match,
    :company,
    :stripe_charge_id,
    :stripe_brand,
    :stripe_last_four,
  ].freeze

  # Overwrite this method to customize how donations are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(donation)
  #   "Donation ##{donation.id}"
  # end
end
