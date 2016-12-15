require "administrate/base_dashboard"

class ReferralDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    family: Field::BelongsTo,
    referral_method: Field::BelongsTo,
    id: Field::Number,
    details: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :family,
    :referral_method,
    :id,
    :details,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :family,
    :referral_method,
    :id,
    :details,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :family,
    :referral_method,
    :details,
  ].freeze

  # Overwrite this method to customize how referrals are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(referral)
  #   "Referral ##{referral.id}"
  # end
end