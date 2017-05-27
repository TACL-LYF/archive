require "administrate/base_dashboard"

class RegistrationDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    camp: Field::BelongsTo,
    camper: Field::BelongsTo,
    family: FamilyField,
    primary_parent_email: Field::String,
    primary_parent_phone_number: Field::String,
    birthdate: Field::DateTime,
    gender: EnumField.with_options(searchable: false),
    medical_conditions_and_medication: Field::Text,
    diet_and_food_allergies: Field::Text,
    returning: Field::Boolean,
    registration_payment: Field::BelongsTo,
    id: Field::Number,
    grade: Field::Number,
    shirt_size: ShirtSizeField.with_options(searchable: false),
    bus: Field::Boolean,
    additional_notes: Field::Text,
    waiver_signature: Field::String,
    waiver_date: Field::DateTime,
    group: EnumField.with_options(searchable: false),
    camp_family: Field::String,
    cabin: Field::String,
    city: Field::String,
    state: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    additional_shirts: Field::AdditionalShirtsField,
    camper_involvement: Field::CamperInvolvementField,
    jtasa_chapter: Field::String,
    preregistration: Field::Boolean,
    status: EnumField.with_options(searchable: false),
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :created_at,
    :camper,
    :family,
    :primary_parent_email,
    :primary_parent_phone_number,
    :city,
    :birthdate,
    :grade,
    :gender,
    :returning,
    :bus,
    :shirt_size,
    :additional_shirts,
    :medical_conditions_and_medication,
    :diet_and_food_allergies,
    :additional_notes,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :camp,
    :status,
    :camper,
    :grade,
    :shirt_size,
    :additional_shirts,
    :bus,
    :additional_notes,
    :camper_involvement,
    :jtasa_chapter,
    :group,
    :camp_family,
    :cabin,
    :registration_payment,
    :city,
    :state,
    :preregistration,
    :waiver_signature,
    :waiver_date,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :camp,
    :camper,
    :grade,
    :shirt_size,
    :bus,
    :additional_notes,
    :preregistration,
    :waiver_signature,
    :waiver_date,
    :group,
    :camp_family,
    :cabin,
    :city,
    :state,
    :additional_shirts,
    :camper_involvement,
    :jtasa_chapter,
    :status,
  ].freeze

  # Overwrite this method to customize how registrations are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(registration)
    "#{registration.camp.year} Registration - #{registration.camper.full_name}"
  end
end
