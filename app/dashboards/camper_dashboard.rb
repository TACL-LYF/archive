require "administrate/base_dashboard"

class CamperDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    family: Field::BelongsTo,
    registrations: Field::HasMany,
    id: Field::Number,
    first_name: Field::String,
    last_name: Field::String,
    birthdate: Field::DateTime,
    gender: Field::String.with_options(searchable: false),
    email: Field::String,
    medical_conditions_and_medication: Field::Text,
    diet_and_food_allergies: Field::Text,
    status: Field::String.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    returning: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :family,
    :registrations,
    :id,
    :first_name,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :family,
    :registrations,
    :id,
    :first_name,
    :last_name,
    :birthdate,
    :gender,
    :email,
    :medical_conditions_and_medication,
    :diet_and_food_allergies,
    :status,
    :created_at,
    :updated_at,
    :returning,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :family,
    :registrations,
    :first_name,
    :last_name,
    :birthdate,
    :gender,
    :email,
    :medical_conditions_and_medication,
    :diet_and_food_allergies,
    :status,
    :returning,
  ].freeze

  # Overwrite this method to customize how campers are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(camper)
    "#{camper.first_name} #{camper.last_name}"
  end
end
