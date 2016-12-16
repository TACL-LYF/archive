require "administrate/base_dashboard"

class FamilyDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    campers: Field::HasMany,
    referrals: Field::HasMany,
    referral_methods: Field::HasMany,
    id: Field::Number,
    primary_parent_first_name: Field::String,
    primary_parent_last_name: Field::String,
    primary_parent_email: Field::String,
    primary_parent_phone_number: Field::String,
    secondary_parent_first_name: Field::String,
    secondary_parent_last_name: Field::String,
    secondary_parent_email: Field::String,
    secondary_parent_phone_number: Field::String,
    suite: Field::String,
    street: Field::String,
    city: Field::String,
    state: Field::String,
    zip: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :primary_parent_first_name,
    :primary_parent_last_name,
    :primary_parent_email,
    :primary_parent_phone_number,
    :city,
    :campers,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :primary_parent_email,
    :primary_parent_phone_number,
    :secondary_parent_first_name,
    :secondary_parent_last_name,
    :secondary_parent_email,
    :secondary_parent_phone_number,
    :street,
    :suite,
    :city,
    :state,
    :zip,
    :campers,
    :referrals,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :primary_parent_first_name,
    :primary_parent_last_name,
    :primary_parent_email,
    :primary_parent_phone_number,
    :secondary_parent_first_name,
    :secondary_parent_last_name,
    :secondary_parent_email,
    :secondary_parent_phone_number,
    :street,
    :suite,
    :city,
    :state,
    :zip,
    :campers,
  ].freeze

  # Overwrite this method to customize how families are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(family)
    "#{family.primary_parent_first_name} #{family.primary_parent_last_name}"
  end
end
